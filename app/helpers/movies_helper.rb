module MoviesHelper
  # Повертає Bootstrap-бейдж відповідного кольору залежно від рейтингу фільму.
  # rating >= 8.0  → badge bg-success  (високий)
  # rating >= 6.0  → badge bg-warning  (середній)
  # rating < 6.0   → badge bg-secondary (низький)
  # rating nil     → badge bg-light     (немає оцінки)
  def rating_badge(movie)
    if movie.rating.nil?
      content_tag(:span, 'немає оцінки', class: 'badge bg-light text-dark')
    elsif movie.rating >= 8.0
      content_tag(:span, "⭐ #{movie.rating}", class: 'badge bg-success')
    elsif movie.rating >= 6.0
      content_tag(:span, "⭐ #{movie.rating}", class: 'badge bg-warning text-dark')
    else
      content_tag(:span, "⭐ #{movie.rating}", class: 'badge bg-secondary')
    end
  end
end
