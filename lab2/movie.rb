class Movie
  # attr_accessor автоматично створює геттери та сеттери для всіх полів
  attr_accessor :title, :genres, :directors, :actors, :release_date, :rating, :status

  # Конструктор з обов'язковими полями. Статус має значення за замовчуванням
  def initialize(title, genres, directors, actors, release_date, rating, status = "want_to_watch")
    @title = title
    @genres = genres
    @directors = directors
    @actors = actors
    @release_date = release_date
    @rating = rating
    @status = status
  end

  # Метод для конвертації об'єкта в хеш (необхідно для JSON)
  def to_h
    {
      title: @title,
      genres: @genres,
      directors: @directors,
      actors: @actors,
      release_date: @release_date,
      rating: @rating,
      status: @status
    }
  end

  # Метод КЛАСУ (self) для відновлення об'єкта з хешу (при завантаженні з JSON)
  def self.from_h(hash)
    # Підтримуємо як рядкові, так і символьні ключі (JSON повертає рядкові)
    new(
      hash['title'] || hash[:title],
      hash['genres'] || hash[:genres],
      hash['directors'] || hash[:directors],
      hash['actors'] || hash[:actors],
      hash['release_date'] || hash[:release_date],
      hash['rating'] || hash[:rating],
      hash['status'] || hash[:status]
    )
  end
end