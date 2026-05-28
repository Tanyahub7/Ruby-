require_relative 'movie_manager'

class App
  YAML_FILE = 'movies.yml'
  JSON_FILE = 'movies.json'

  def initialize
    @manager = MovieManager.new
    load_initial_data
  end

  def run
    loop do
      print_menu
      choice = gets.chomp.to_i

      break if choice == 0 # Вихід з циклу

      process_choice(choice)
    end
    puts "👋 Завершення роботи..."
  ensure
    # Цей блок виконається ЗАВЖДИ при виході з програми (навіть при помилці чи Ctrl+C)
    @manager.save_to_yaml(YAML_FILE)
    puts "💾 Дані автоматично збережено у файл #{YAML_FILE}."
  end

  private

  def load_initial_data
    if @manager.load_from_yaml(YAML_FILE)
      puts "📂 Дані успішно завантажено з YAML."
    elsif @manager.load_from_json(JSON_FILE)
      puts "📂 Дані успішно завантажено з JSON."
    else
      puts "✨ Створено новий порожній каталог."
    end
  end

  def print_menu
    puts "\n" + "="*30
    puts "🎬 КАТАЛОГ ФІЛЬМІВ"
    puts "="*30
    puts "1. Список всіх фільмів"
    puts "2. Додати фільм"
    puts "3. Змінити статус фільму (watched/watching/want_to_watch)"
    puts "4. Видалити фільм"
    puts "5. Пошук за назвою"
    puts "6. Фільтр за жанром"
    puts "7. Зберегти вручну у JSON"
    puts "0. Вийти"
    print "Оберіть опцію: "
  end

  def process_choice(choice)
    puts "-"*30
    case choice
    when 1 then @manager.list_movies
    when 2 then prompt_add_movie
    when 3 then prompt_edit_movie
    when 4 then prompt_delete_movie
    when 5 then prompt_search
    when 6 then prompt_filter
    when 7
      @manager.save_to_json(JSON_FILE)
      puts "✅ Дані збережено у #{JSON_FILE}"
    else
      puts "❌ Невідома команда. Спробуйте ще раз."
    end
  end

  def prompt_add_movie
    print "Назва: "; title = gets.chomp
    print "Жанри (через кому): "; genres = gets.chomp.split(',').map(&:strip)
    print "Режисери (через кому): "; directors = gets.chomp.split(',').map(&:strip)
    print "Актори (через кому): "; actors = gets.chomp.split(',').map(&:strip)
    print "Дата виходу (YYYY-MM-DD): "; date = gets.chomp
    print "Рейтинг: "; rating = gets.chomp.to_f

    @manager.add_movie(title, genres, directors, actors, date, rating)
  end

  def prompt_edit_movie
    print "Введіть ID фільму: "; id = gets.chomp.to_i
    print "Введіть новий статус: "; status = gets.chomp
    @manager.edit_movie(id, { status: status })
  end

  def prompt_delete_movie
    print "Введіть ID фільму для видалення: "; id = gets.chomp.to_i
    print "Ви впевнені? (y/n): "
    if gets.chomp.downcase == 'y'
      @manager.delete_movie(id)
    else
      puts "Видалення скасовано."
    end
  end

  def prompt_search
    print "Введіть назву (або частину): "; query = gets.chomp
    @manager.find_by_title(query)
  end

  def prompt_filter
    print "Введіть жанр для пошуку: "; genre = gets.chomp
    @manager.filter_by_genre(genre)
  end
end

# Запуск програми
App.new.run if __FILE__ == $PROGRAM_NAME