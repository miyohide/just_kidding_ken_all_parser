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
      t.integer :todofuken_number
      t.timestamps
    end

    create_table :cities do |t|
      t.string :city_kanji
      t.string :city_kana
      t.string :city_hira
      t.integer :todofuken_number
      t.integer :city_number
      t.timestamps
    end

    create_table :towns do |t|
      t.string :town_kanji
      t.string :town_kana
      t.string :town_hira
      t.integer :todofuken_number
      t.integer :city_number
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
todofuken_number = 0
city_number = 0
old_todofuken = ""
old_city = ""
old_town = ""

CSV.foreach("KEN_ALL.CSV", encoding: "Shift_JIS:UTF-8") do |row|
  #  CSVファイルの構造
  #  0 : 全国地方公共団体コード
  #  1 :  （旧）郵便番号（5桁）
  #  2 :  郵便番号（7桁）
  #  3 :  都道府県名（半角カタカナ）
  #  4 :  市区町村名（半角カタカナ）
  #  5 :  町区名（半角カタカナ）
  #  6 :  都道府県名（漢字）
  #  7 :  市区町村名（漢字）
  #  8 :  町区名（漢字）
  #  9 :  一町域が二以上の郵便番号で表される場合の表示
  # 10 :  小字毎に番地が起番されている場合の表示
  # 11 :  丁目を有する町域の場合の表示
  # 12 :  一つの郵便番号で二以上の町域を表す場合の表示
  # 13 :  更新の表示
  # 14 :  変更理由
  next if row[8] == "以下に掲載がない場合"
  next if row[9] == "1"
  next if row[5] =~ /\d/

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
    todofuken_number += 1
    Todofuken.create!(
      todofuken_kanji: row[6],
      todofuken_kana:  todofuken_kana,
      todofuken_hira:  todofuken_hira,
      todofuken_number: todofuken_number)
    old_todofuken = row[6]
  end

  if old_city != row[7]
    city_number += 1
    City.create!(
      city_kanji:  row[7],
      city_kana:   city_kana,
      city_hira:   city_hira,
      todofuken_number: todofuken_number,
      city_number: city_number)
    old_city = row[7]
  end

  Town.create!(
    town_kanji:  town_kanji,
    town_kana:   town_kana,
    town_hira:   town_hira,
    todofuken_number: todofuken_number,
    city_number: city_number)

  i += 1
  puts "#{i - 1}件保存しました。" if i % 1000 == 0

end

