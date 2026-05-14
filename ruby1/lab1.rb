# =============================================================================
# Варіант 2 — Каталог фільмів
# Набір функцій для керування колекцією фільмів
# =============================================================================

require 'json'
require 'yaml'
require 'date'

# -----------------------------------------------------------------------------
# ДОПОМІЖНА ФУНКЦІЯ: генерація нового ID
# Повертає максимальний існуючий ключ + 1, або 1 якщо колекція порожня
# -----------------------------------------------------------------------------
def next_id(collection)
  collection.empty? ? 1 : collection.keys.max + 1
end

# -----------------------------------------------------------------------------
# ДОПОМІЖНА ФУНКЦІЯ: перевірка статусу
# Допустимі статуси: want_to_watch, watching, watched
# -----------------------------------------------------------------------------
VALID_STATUSES = %w[want_to_watch watching watched].freeze

def valid_status?(status)
  VALID_STATUSES.include?(status.to_s)
end

# =============================================================================
# CRUD — основні операції
# =============================================================================

# Додає новий фільм до колекції.
# Параметри:
#   collection  — хеш колекції фільмів (змінюється in-place)
#   title       — назва фільму (String)
#   genres      — жанри (Array of String)
#   directors   — режисери (Array of String)
#   actors      — актори (Array of String)
#   release_date— дата виходу у форматі "YYYY-MM-DD" (String)
#   rating      — рейтинг від 0.0 до 10.0 (Float)
#   status      — статус перегляду: want_to_watch / watching / watched
# Повертає ID нового запису
def add_movie(collection, title:, genres: [], directors: [], actors: [],
              release_date: nil, rating: nil, status: 'want_to_watch')
  # Перевірка обов'язкових полів
  raise ArgumentError, "Назва фільму не може бути порожньою" if title.to_s.strip.empty?
  raise ArgumentError, "Недійсний статус: '#{status}'" unless valid_status?(status)
  raise ArgumentError, "Рейтинг має бути від 0 до 10" if rating && !(0.0..10.0).cover?(rating.to_f)

  id = next_id(collection)

  # Записуємо новий фільм із символьними ключами
  collection[id] = {
    title:        title.strip,
    genres:       Array(genres),
    directors:    Array(directors),
    actors:       Array(actors),
    release_date: release_date,
    rating:       rating ? rating.to_f.round(1) : nil,
    status:       status.to_s
  }

  puts "✅ Фільм '#{title}' додано з ID=#{id}"
  id
end

# -----------------------------------------------------------------------------
# Редагує поля існуючого запису за ID.
# new_data — хеш із полями, які потрібно оновити (символьні або рядкові ключі).
# Нові значення merge-яться поверх існуючих.
# -----------------------------------------------------------------------------
def edit_movie(collection, id, new_data)
  # Перевірка існування запису
  unless collection.key?(id)
    puts "❌ Фільм з ID=#{id} не знайдено"
    return false
  end

  # Нормалізуємо ключі new_data до символів
  normalized = new_data.transform_keys(&:to_sym)

  # Перевірка статусу, якщо він оновлюється
  if normalized.key?(:status) && !valid_status?(normalized[:status])
    raise ArgumentError, "Недійсний статус: '#{normalized[:status]}'"
  end

  # Перевірка рейтингу, якщо він оновлюється
  if normalized.key?(:rating) && normalized[:rating] && !(0.0..10.0).cover?(normalized[:rating].to_f)
    raise ArgumentError, "Рейтинг має бути від 0 до 10"
  end

  # Округлюємо рейтинг якщо передано
  normalized[:rating] = normalized[:rating].to_f.round(1) if normalized.key?(:rating) && normalized[:rating]

  # Оновлюємо лише передані поля
  collection[id].merge!(normalized)
  puts "✏️  Фільм ID=#{id} оновлено"
  true
end

# -----------------------------------------------------------------------------
# Видаляє запис за ID.
# Повертає хеш видаленого запису або nil якщо не знайдено.
# -----------------------------------------------------------------------------
def delete_movie(collection, id)
  unless collection.key?(id)
    puts "❌ Фільм з ID=#{id} не знайдено"
    return nil
  end

  deleted = collection.delete(id)
  puts "🗑️  Фільм '#{deleted[:title]}' (ID=#{id}) видалено"
  deleted
end

# -----------------------------------------------------------------------------
# Виводить усі фільми у зручному форматі (таблиця в термінал).
# Якщо колекція порожня — повідомляє про це.
# -----------------------------------------------------------------------------
def list_movies(collection)
  if collection.empty?
    puts "📭 Каталог порожній"
    return
  end

  puts "\n#{"─" * 70}"
  puts " 🎬 КАТАЛОГ ФІЛЬМІВ (#{collection.size} шт.)"
  puts "─" * 70

  collection.each do |id, movie|
    rating_str = movie[:rating] ? "⭐ #{movie[:rating]}" : "— немає рейтингу"
    status_emoji = { 'want_to_watch' => '📌', 'watching' => '▶️ ', 'watched' => '✅' }
    status_label = status_emoji.fetch(movie[:status], '?') + " #{movie[:status]}"

    puts "  ID: #{id}"
    puts "  Назва:    #{movie[:title]}"
    puts "  Жанри:    #{movie[:genres].join(', ')}"
    puts "  Режисер:  #{movie[:directors].join(', ')}"
    puts "  Актори:   #{movie[:actors].join(', ')}"
    puts "  Дата:     #{movie[:release_date] || '—'}"
    puts "  Рейтинг:  #{rating_str}"
    puts "  Статус:   #{status_label}"
    puts "─" * 70
  end
  puts
end

# =============================================================================
# ПОШУК — за частковим збігом значення поля
# =============================================================================

# Шукає фільми, назва яких містить рядок query (без урахування регістру).
# Повертає хеш підходящих записів.
def find_by_title(collection, query)
  q = query.to_s.downcase
  result = collection.select { |_, movie| movie[:title].downcase.include?(q) }

  if result.empty?
    puts "🔍 За запитом '#{query}' (поле: title) нічого не знайдено"
  else
    puts "🔍 Знайдено #{result.size} фільм(ів) за назвою '#{query}':"
    list_movies(result)
  end

  result
end

# Шукає фільми, де ім'я актора містить рядок query.
def find_by_actor(collection, query)
  q = query.to_s.downcase
  result = collection.select do |_, movie|
    movie[:actors].any? { |actor| actor.downcase.include?(q) }
  end

  if result.empty?
    puts "🔍 За запитом '#{query}' (поле: actors) нічого не знайдено"
  else
    puts "🔍 Знайдено #{result.size} фільм(ів) з актором '#{query}':"
    list_movies(result)
  end

  result
end

# =============================================================================
# ФІЛЬТРАЦІЯ — специфічна для каталогу фільмів
# =============================================================================

# Фільтрує фільми за жанром (точний збіг без урахування регістру).
# genre — рядок жанру, наприклад "Drama"
# Повертає хеш відповідних записів.
def filter_by_genre(collection, genre)
  g = genre.to_s.downcase
  result = collection.select do |_, movie|
    movie[:genres].any? { |gn| gn.downcase == g }
  end

  if result.empty?
    puts "🎭 Фільмів у жанрі '#{genre}' не знайдено"
  else
    puts "🎭 Фільми жанру '#{genre}' (#{result.size} шт.):"
    list_movies(result)
  end

  result
end

# Фільтрує фільми за ім'ям режисера (часткове співпадіння без урахування регістру).
# Повертає хеш відповідних записів.
def filter_by_director(collection, director)
  d = director.to_s.downcase
  result = collection.select do |_, movie|
    movie[:directors].any? { |dir| dir.downcase.include?(d) }
  end

  if result.empty?
    puts "🎬 Фільмів режисера '#{director}' не знайдено"
  else
    puts "🎬 Фільми режисера '#{director}' (#{result.size} шт.):"
    list_movies(result)
  end

  result
end

# Фільтрує фільми за статусом перегляду.
# status — один із: want_to_watch, watching, watched
# Повертає хеш відповідних записів.
def filter_by_status(collection, status)
  unless valid_status?(status)
    puts "❌ Недійсний статус '#{status}'. Допустимі: #{VALID_STATUSES.join(', ')}"
    return {}
  end

  result = collection.select { |_, movie| movie[:status] == status.to_s }

  if result.empty?
    puts "📋 Фільмів зі статусом '#{status}' не знайдено"
  else
    puts "📋 Фільми зі статусом '#{status}' (#{result.size} шт.):"
    list_movies(result)
  end

  result
end

# Фільтрує фільми за мінімальним рейтингом.
# min_rating — мінімально допустимий рейтинг (Float)
# Повертає хеш відповідних записів, відсортованих за рейтингом (спадання).
def filter_by_min_rating(collection, min_rating)
  result = collection.select do |_, movie|
    movie[:rating] && movie[:rating] >= min_rating.to_f
  end

  # Сортування за рейтингом від більшого до меншого
  sorted = result.sort_by { |_, movie| -movie[:rating] }.to_h

  if sorted.empty?
    puts "⭐ Фільмів з рейтингом >= #{min_rating} не знайдено"
  else
    puts "⭐ Фільми з рейтингом >= #{min_rating} (#{sorted.size} шт.):"
    list_movies(sorted)
  end

  sorted
end

# =============================================================================
# РОБОТА З ФАЙЛАМИ
# =============================================================================

# Зберігає колекцію у файл JSON.
# Ключі (Integer) конвертуються у рядки (обмеження формату JSON).
def save_to_json(collection, filename)
  # Конвертуємо Integer-ключі у рядки для сумісності з JSON
  serializable = collection.transform_keys(&:to_s).transform_values do |movie|
    movie.transform_keys(&:to_s)
  end

  File.write(filename, JSON.pretty_generate(serializable))
  puts "💾 Колекцію збережено у '#{filename}'"
rescue Errno::ENOENT => e
  puts "❌ Помилка запису файлу '#{filename}': #{e.message}"
rescue StandardError => e
  puts "❌ Несподівана помилка при збереженні JSON: #{e.message}"
end

# Завантажує колекцію з файлу JSON.
# Повертає хеш із Integer-ключами та символьними ключами полів.
def load_from_json(filename)
  raw = File.read(filename)
  parsed = JSON.parse(raw)

  # Відновлюємо Integer-ключі та символьні ключі полів
  parsed.transform_keys { |k| k.to_i }.transform_values do |movie|
    movie.transform_keys(&:to_sym)
  end
rescue Errno::ENOENT
  puts "❌ Файл '#{filename}' не знайдено"
  {}
rescue JSON::ParserError => e
  puts "❌ Помилка парсингу JSON з '#{filename}': #{e.message}"
  {}
rescue StandardError => e
  puts "❌ Несподівана помилка при завантаженні JSON: #{e.message}"
  {}
end

# Зберігає колекцію у файл YAML.
def save_to_yaml(collection, filename)
  # Конвертуємо символьні ключі у рядки для стандартного YAML
  serializable = collection.transform_keys(&:to_s).transform_values do |movie|
    movie.transform_keys(&:to_s)
  end

  File.write(filename, serializable.to_yaml)
  puts "💾 Колекцію збережено у '#{filename}'"
rescue Errno::ENOENT => e
  puts "❌ Помилка запису файлу '#{filename}': #{e.message}"
rescue StandardError => e
  puts "❌ Несподівана помилка при збереженні YAML: #{e.message}"
end

# Завантажує колекцію з файлу YAML.
# Повертає хеш із Integer-ключами та символьними ключами полів.
def load_from_yaml(filename)
  raw = YAML.safe_load(File.read(filename), permitted_classes: [Symbol])

  raw.transform_keys { |k| k.to_i }.transform_values do |movie|
    movie.transform_keys(&:to_sym)
  end
rescue Errno::ENOENT
  puts "❌ Файл '#{filename}' не знайдено"
  {}
rescue Psych::SyntaxError => e
  puts "❌ Помилка парсингу YAML з '#{filename}': #{e.message}"
  {}
rescue StandardError => e
  puts "❌ Несподівана помилка при завантаженні YAML: #{e.message}"
  {}
end

# =============================================================================
# ДЕМОНСТРАЦІЯ РОБОТИ
# =============================================================================

if __FILE__ == $PROGRAM_NAME
  puts "=" * 70
  puts "  🎬 Демонстрація каталогу фільмів"
  puts "=" * 70

  # --- Початкова колекція ---
  movies = {
    1 => {
      title:        "Inception",
      genres:       ["Sci-Fi", "Action", "Thriller"],
      directors:    ["Christopher Nolan"],
      actors:       ["Leonardo DiCaprio", "Tom Hardy"],
      release_date: "2010-07-16",
      rating:       8.8,
      status:       "want_to_watch"
    },
    2 => {
      title:        "The Shawshank Redemption",
      genres:       ["Drama"],
      directors:    ["Frank Darabont"],
      actors:       ["Tim Robbins", "Morgan Freeman"],
      release_date: "1994-09-23",
      rating:       9.3,
      status:       "watched"
    }
  }

  # 1. Вивести всі фільми
  puts "\n📋 Початковий каталог:"
  list_movies(movies)

  # 2. Додати новий фільм
  puts "\n➕ Додаємо новий фільм..."
  add_movie(
    movies,
    title:        "Interstellar",
    genres:       ["Sci-Fi", "Drama"],
    directors:    ["Christopher Nolan"],
    actors:       ["Matthew McConaughey", "Anne Hathaway"],
    release_date: "2014-11-07",
    rating:       8.6,
    status:       "watching"
  )

  add_movie(
    movies,
    title:        "The Godfather",
    genres:       ["Crime", "Drama"],
    directors:    ["Francis Ford Coppola"],
    actors:       ["Marlon Brando", "Al Pacino"],
    release_date: "1972-03-24",
    rating:       9.2,
    status:       "watched"
  )

  # 3. Редагувати фільм
  puts "\n✏️  Редагуємо фільм ID=1..."
  edit_movie(movies, 1, { status: "watched", rating: 8.9 })

  # 4. Пошук за назвою
  puts "\n🔍 Пошук за назвою 'the':"
  find_by_title(movies, "the")

  # 5. Пошук за актором
  puts "\n🔍 Пошук за актором 'Nolan':"
  find_by_actor(movies, "DiCaprio")

  # 6. Фільтр за жанром
  puts "\n🎭 Фільтр за жанром 'Drama':"
  filter_by_genre(movies, "Drama")

  # 7. Фільтр за режисером
  puts "\n🎬 Фільтр за режисером 'Nolan':"
  filter_by_director(movies, "Nolan")

  # 8. Фільтр за статусом
  puts "\n📌 Фільтр за статусом 'watched':"
  filter_by_status(movies, "watched")

  # 9. Фільтр за мінімальним рейтингом
  puts "\n⭐ Фільтр за рейтингом >= 9.0:"
  filter_by_min_rating(movies, 9.0)

  # 10. Видалення фільму
  puts "\n🗑️  Видаляємо фільм ID=2..."
  delete_movie(movies, 2)

  # 11. Спроба видалити неіснуючий запис
  puts "\n🗑️  Спроба видалити неіснуючий ID=99:"
  delete_movie(movies, 99)

  # 12. Збереження та завантаження JSON
  puts "\n💾 Зберігаємо у JSON..."
  save_to_json(movies, "/tmp/movies.json")

  puts "\n📂 Завантажуємо з JSON..."
  loaded_json = load_from_json("/tmp/movies.json")
  puts "Завантажено #{loaded_json.size} фільм(ів) з JSON"

  # 13. Збереження та завантаження YAML
  puts "\n💾 Зберігаємо у YAML..."
  save_to_yaml(movies, "/tmp/movies.yaml")

  puts "\n📂 Завантажуємо з YAML..."
  loaded_yaml = load_from_yaml("/tmp/movies.yaml")
  puts "Завантажено #{loaded_yaml.size} фільм(ів) з YAML"

  # 14. Спроба завантажити неіснуючий файл
  puts "\n📂 Спроба завантажити неіснуючий файл:"
  load_from_json("nonexistent.json")
  load_from_yaml("nonexistent.yaml")

  # 15. Підсумковий вивід
  puts "\n📋 Підсумковий каталог:"
  list_movies(movies)
end
