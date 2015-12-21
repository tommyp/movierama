class VoteMailer < ActionMailer::Base
  default from: "no-reply@movierama.dev"

  def notify_author(movie_id, voting_user_id, like_or_hate)
    @movie = Movie[movie_id]
    @author = @movie.user
    @voting_user = User[voting_user_id]
    @like_or_hate_verb = case like_or_hate
                         when :like
                          "liked"
                         when :hate
                          "hated"
                         end

    mail(
      to: @author.email,
      subject: "#{@voting_user.name} #{@like_or_hate_verb} #{@movie.title}",
    )
  end
end
