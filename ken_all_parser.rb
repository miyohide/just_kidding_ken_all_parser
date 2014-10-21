require "csv"
require "nkf"
require "active_record"

ActiveRecord::Base.establish_connection(
   adapter: 'postgresql',
   host:    'localhost',
   username: 'user1',
   password: 'user1',
   database: 'ken_all'
)

class InitialSchema < ActiveRecord::Migration
   def change
      create_table :todofukens do |t|
         t.string :todofuken_kanji
         t.string :todofuken_kana
         t.string :todofuken_hira
         t.timestamps
      end

      create_table :cities do |t|
         t.string :city_kanji
         t.string :city_kana
         t.string :city_hira
         t.timestamps
      end

      create_table :towns do |t|
         t.string :town_kanji
         t.string :town_kana
         t.string :town_hira
         t.timestamps
      end
   end
end

InitialSchema.migrate(:up)

class Todofuken < ActiveRecord::Base
end

class City < ActiveRecord::Base
end

class Town < ActiveRecord::Base
end

i = 0
old_todofuken = ""
old_city = ""
old_town = ""

CSV.foreach("KEN_ALL.CSV", encoding: "Shift_JIS:UTF-8") do |row|
   next if row[8] == "以下に記載がない場合"
   next if row[9] == "1"

   todofuken_kana = NKF.nkf("-Xw", row[3])
   todofuken_hira = NKF.nkf("--hiragana -w", row[3])
   city_kana = NKF.nkf("-Xw", row[4])
   city_hira = NKF.nkf("--hiragana -w", row[4])
   row[5].gsub!(/\(.+/, "")  # (で町名などの但し書きを書いているものを削除
   if row[5] == old_town
      next
   else
      old_town = row[5]
   end
   town_kana = NKF.nkf("-Xw", row[5])
   town_hira = NKF.nkf("--hiragana -w", row[5])

   town_kanji = row[8].gsub(/（.+/, "")

   if old_todofuken != row[6]
      Todofuken.create!(
         todofuken_kanji: row[6],
         todofuken_kana:  todofuken_kana,
         todofuken_hira:  todofuken_hira)
      old_todofuken = row[6]
   end

   if old_city != row[7]
      City.create!(
         city_kanji:  row[7],
         city_kana:   city_kana,
         city_hira:   city_hira)
      old_city = row[7]
   end

   Town.create!(
      town_kanji:  town_kanji,
      town_kana:   town_kana,
      town_hira:   town_hira)

   i += 1
   puts "#{i - 1}件保存しました。" if i % 1000 == 0


end

