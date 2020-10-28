# frozen_string_literal: true

require 'securerandom'

class EtdStructureTrainingDataProcessor
  attr_reader :druid, :pages, :page_count

  def initialize(druid, pages)
    @druid = druid
    @pages = pages
    @page_count = pages.count
  end

  def get_training_data(tocs: true, texts: true, bibs: true)
    unless valid?
      puts "Druid #{druid} is too small to get take a sampling (#{page_count} pages)"
    end

    possible_tocs.each do |toc|
      puts '********' * 10
      puts toc
      puts '********' * 10
      puts "Does the page above look like a TOC?"
      if ['yes', 'y'].include?gets.chomp.downcase
        File.open("#{training_data_dir}/known_tocs/#{SecureRandom.uuid}.txt", 'w') do |f|
          f.write toc
        end
      end
    end if tocs

    possible_texts.each do |text|
      puts '********' * 10
      puts text
      puts '********' * 10
      puts "Does the page above look like normal page text?"
      if ['yes', 'y'].include? gets.chomp.downcase
        File.open("#{training_data_dir}/known_text/#{SecureRandom.uuid}.txt", 'w') do |f|
          f.write text
        end
      end
    end if texts

    possible_bibs.each do |bib|
      puts '********' * 10
      puts bib
      puts '********' * 10
      puts "Does the page above include bibliography/citations/references?"

      if ['yes', 'y'].include? gets.chomp.downcase
        File.open("#{training_data_dir}/known_bibs/#{SecureRandom.uuid}.txt", 'w') do |f|
          f.write bib
        end
      end
    end if bibs
  end

  private

  def valid?
    page_count > 20
  end

  # Pages 5 - 10
  def possible_tocs
    pages[5, 5]
  end

  # 5 random pages selected from pages 0 - 5 and then the 2nd quarter of the book
  def possible_texts
    @possible_texts ||= (pages[0, 5] + pages[(page_count / 4)...(page_count / 2)]).sample(5)
  end

  # Last 5 pages
  def possible_bibs
    pages.last(5)
  end

  def training_data_dir
    "#{__dir__}/training_data"
  end
end
