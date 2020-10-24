require 'nbayes'

class EtdStructureClassifier
  def inspect
    "<EtdStructureClassifier id=\"##{object_id}\" persisted=\"#{persisted?}\">"
  end

  def persist!
    model.dump(persisted_model)

    self
  end

  def persisted?
    File.exists?(persisted_model)
  end

  def clear!
    File.delete(persisted_model) if persisted?

    self
  end

  def classify(text)
    model.classify(tokenize_text(text)).max_class
  end

  def train
    train_model(toc_files[:train], 'TOC')
    train_model(text_files[:train], 'TEXT')
    train_model(bib_files[:train], 'BIB')

    self
  end

  def test
    toc_results = run_test(toc_files[:test], 'TOC')
    text_results = run_test(text_files[:test], 'TEXT')
    bib_results = run_test(bib_files[:test], 'BIB')

    puts "Training size: #{toc_files[:train].count + text_files[:train].count + bib_files[:train].count} (#{toc_files[:train].count} TOCs + #{text_files[:train].count} texts + #{bib_files[:train].count} bibs)"
    puts "TOC results: #{toc_results.count { |r| r == 'TOC' }} of #{toc_results.count} were predicted accurately"
    puts "Text results: #{text_results.count { |r| r == 'TEXT' }} of #{text_results.count} were predicted accurately"
    puts "Bib results: #{bib_results.count { |r| r == 'BIB' }} of #{bib_results.count} were predicted accurately"
  end

  private

  def train_model(filenames, label)
    filenames.each do |filename|
      file = File.open(filename, 'r').read
      model.train(tokenize_text(file), label)
    end
  end

  def run_test(files, label)
    files.map do |test_file|
      test_file = File.open(test_file, 'r').read
      classified = model.classify(tokenize_text(test_file))
      if classified.max_class != label
        puts "#{classified} did not predict #{label} successfully (got #{classified.max_class})"
        puts '********' * 10
        puts test_file
        puts '********' * 10
      end
      classified.max_class
    end
  end

  def split_files(files)
    files = files.shuffle
    {
      train: files[0, files.length - 20],
      test: files[-20, 20]
    }
  end

  def model
    @model ||= persisted? ? NBayes::Base.new.load(persisted_model) : NBayes::Base.new
  end

  def persisted_model
    '.nb_model'
  end

  def toc_files
    @toc_files ||= split_files(Dir['./training_data/known_tocs/*.txt'])
  end

  def text_files
    @text_files ||= split_files(Dir['./training_data/known_text/*.txt'])
  end

  def bib_files
    @bib_files ||= split_files(Dir['./training_data/known_bibs/*.txt'])
  end

  def tokenize_text(text)
    return text.split(/\s+/).map(&:downcase)# .map {|s| s[/[a-zA-Z0-9]+/] }
  end
end
