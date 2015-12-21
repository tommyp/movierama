require 'rails_helper'
require 'capybara/rails'
require 'support/pages/movie_list'
require 'support/pages/movie_new'
require 'support/with_user'

RSpec.describe 'vote on movies', type: :feature do

  let(:page) { Pages::MovieList.new }

  before do
    author = User.create(
      uid:  'null|12345',
      name: 'Bob',
      email: 'bob@movierama.dev'
    )
    Movie.create(
      title:        'Empire strikes back',
      description:  'Who\'s scruffy-looking?',
      date:         '1980-05-21',
      user:         author
    )

    ActionMailer::Base.deliveries = []
  end

  context 'when logged out' do
    it 'cannot vote' do
      page.open
      expect {
        page.like('Empire strikes back')
      }.to raise_error(Capybara::ElementNotFound)
    end
  end

  context 'when logged in' do
    with_logged_in_user

    before { page.open }

    it 'can like' do
      page.like('Empire strikes back')
      expect(page).to have_vote_message
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.subject).to eq('John McFoo liked Empire strikes back')
      expect(ActionMailer::Base.deliveries.first.to).to include('bob@movierama.dev')
    end

    it 'can hate' do
      page.hate('Empire strikes back')
      expect(page).to have_vote_message
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.subject).to eq('John McFoo hated Empire strikes back')
      expect(ActionMailer::Base.deliveries.first.to).to include('bob@movierama.dev')
    end

    it 'can unlike' do
      page.like('Empire strikes back')
      page.unlike('Empire strikes back')
      expect(page).to have_unvote_message
    end

    it 'can unhate' do
      page.hate('Empire strikes back')
      page.unhate('Empire strikes back')
      expect(page).to have_unvote_message
    end

    it 'cannot like twice' do
      expect {
        2.times { page.like('Empire strikes back') }
      }.to raise_error(Capybara::ElementNotFound)
    end

    it 'cannot like own movies' do
      Pages::MovieNew.new.open.submit(
        title:       'The Party',
        date:        '1969-08-13',
        description: 'Birdy nom nom')
      page.open
      expect {
        page.like('The Party')
      }.to raise_error(Capybara::ElementNotFound)
    end
  end

end
