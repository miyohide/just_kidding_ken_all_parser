require 'yaml'
require 'active_record'

ActiveRecord::Base.establish_connection(
   adapter: 'postgresql',
   host:    'localhost',
   username: 'user1',
   password: 'user1',
   database: 'ken_all'
)

class Todofuken < ActiveRecord::Base
end

class City < ActiveRecord::Base
end

class Town < ActiveRecord::Base
end

todofuken = Todofuken.order(:id)
city = City.order(:id)
town = Town.order(:id)

File.open("addresses.yml", "w") { |f|
   f.write("addresses:\n")
   f.write("  prefectural:\n")
   todofuken.each do |record|
      f.write("    - ['#{record.todofuken_kanji}', '#{record.todofuken_hira}', '#{record.todofuken_kana}', #{record.todofuken_number}]\n")
   end
   f.write("  city:\n")
   city.each do |record|
      f.write("    - ['#{record.city_kanji}', '#{record.city_hira}', '#{record.city_kana}', #{record.todofuken_number}, #{record.city_number}]\n")
   end
   f.write("  town:\n")
   town.each do |record|
      if record.town_kanji != '以下に掲載がない場合'
         f.write("    - ['#{record.town_kanji}', '#{record.town_hira}', '#{record.town_kana}', #{record.todofuken_number}, #{record.city_number}]\n")
      end
   end
}

