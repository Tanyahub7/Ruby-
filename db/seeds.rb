# db/seeds.rb

genres = Genre.create!([
  { name: 'Sci-Fi' },
  { name: 'Drama' },
  { name: 'Action' },
  { name: 'Thriller' },
  { name: 'Crime' },
  { name: 'Comedy' }
])

sci_fi   = genres[0]
drama    = genres[1]
action   = genres[2]
thriller = genres[3]
crime    = genres[4]

Movie.create!([
  {
    title:        'Inception',
    genre:        sci_fi,
    director:     'Christopher Nolan',
    release_date: '2010-07-16',
    rating:       8.8,
    status:       :watched
  },
  {
    title:        'The Shawshank Redemption',
    genre:        drama,
    director:     'Frank Darabont',
    release_date: '1994-09-23',
    rating:       9.3,
    status:       :watched
  },
  {
    title:        'Interstellar',
    genre:        sci_fi,
    director:     'Christopher Nolan',
    release_date: '2014-11-07',
    rating:       8.6,
    status:       :watching
  },
  {
    title:        'The Godfather',
    genre:        crime,
    director:     'Francis Ford Coppola',
    release_date: '1972-03-24',
    rating:       9.2,
    status:       :want_to_watch
  },
  {
    title:        'Parasite',
    genre:        thriller,
    director:     'Bong Joon-ho',
    release_date: '2019-05-30',
    rating:       8.5,
    status:       :want_to_watch
  }
])

puts "✅ Seed дані завантажено: #{Genre.count} жанрів, #{Movie.count} фільмів"
