require 'json'
require 'yaml'
require_relative 'movie'

class MovieManager
  def initialize
    @collection = {} # Хеш, де ключ - ID, значення - об'єкт Movie
  end

  # === CRUD ОПЕРАЦІЇ ===

  def add_movie(title, genres, directors, actors, release_date, rating)
    new_id = @collection.keys.max.to_i + 1
    @collection[new_id] = Movie.new(title, genres, directors, actors, release_date, rating)
    puts "✅ Фільм '#{title}' успішно додано з ID: #{new_id}."
  end

  def edit_movie(id, new_data)
    if @collection.key?(id)
      movie = @collection[id]
      # Динамічно викликаємо сеттери (наприклад, title=, rating=)
      new_data.each do |key, value|
        movie.send("#{key}=", value) if movie.respond_to?("#{key}=")
      end
      puts "✅ Фільм з ID #{id} успішно оновлено."
    else
      puts "❌ Помилка: Фільм з ID #{id} не знайдено."
    end
  end

  def delete_movie(id)
    if @collection.delete(id)
      puts "✅ Фільм з ID #{id} видалено."
    else
      puts "❌ Помилка: Фільм з ID #{id} не знайдено."
    end
  end

  def list_movies
    if @collection.empty?
      puts "📭 Каталог порожній."
      return
    end

    @collection.each do |id, movie|
      puts "ID: #{id} | #{movie.title} [#{movie.status}] - Рейтинг: #{movie.rating}"
      puts "   Жанри: #{movie.genres.join(', ')} | Режисер: #{movie.directors.join(', ')}"
    end
  end

  # === ПОШУК ТА ФІЛЬТРАЦІЯ ===

  def find_by_title(query)
    result = @collection.select { |_, movie| movie.title.downcase.include?(query.downcase) }
    print_search_results(result, "назвою '#{query}'")
  end

  def filter_by_genre(genre)
    result = @collection.select { |_, movie| movie.genres.any? { |g| g.downcase == genre.downcase } }
    print_search_results(result, "жанром '#{genre}'")
  end

  # === СЕРІАЛІЗАЦІЯ ===

  def save_to_yaml(filename)
    File.write(filename, YAML.dump(@collection))
  end

  def load_from_yaml(filename)
    return false unless File.exist?(filename)
    # Дозволяємо YAML відновлювати об'єкти класу Movie
    @collection = YAML.safe_load(File.read(filename), permitted_classes: [Symbol, Movie]) || {}
    true
  end

  def save_to_json(filename)
    # Спочатку перетворюємо кожен об'єкт Movie на хеш за допомогою to_h
    hash_collection = @collection.transform_values(&:to_h)
    File.write(filename, JSON.pretty_generate(hash_collection))
  end

  def load_from_json(filename)
    return false unless File.exist?(filename)
    data = JSON.parse(File.read(filename))
    # Відновлюємо ключі як цілі числа, а значення перетворюємо з хешів у об'єкти Movie
    @collection = data.transform_keys(&:to_i).transform_values { |hash| Movie.from_h(hash) }
    true
  rescue JSON::ParserError
    false
  end

  private

  def print_search_results(result, criteria)
    if result.empty?
      puts "🔍 За #{criteria} нічого не знайдено."
    else
      puts "🔍 Знайдено #{result.size} фільмів:"
      result.each { |id, movie| puts "  - [ID: #{id}] #{movie.title}" }
    end
  end
end