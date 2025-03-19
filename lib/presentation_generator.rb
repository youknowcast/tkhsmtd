require_relative 'presenter'
require 'fileutils'

# YAMLファイルからHTMLプレゼンテーションを生成するクラス
class PresentationGenerator
  SCRIPTS_DIR = File.join(File.dirname(__FILE__), '../scripts')
  SLIDES_DIR = File.join(File.dirname(__FILE__), '../slides')

  def initialize
    FileUtils.mkdir_p(SLIDES_DIR)
  end

  def generate_all
    yaml_files = find_yaml_files
    validate_yaml_files(yaml_files)

    results = process_yaml_files(yaml_files)
    display_results(results)
  end

  private

  def find_yaml_files
    Dir.glob(File.join(SCRIPTS_DIR, '*.yml'))
  end

  def validate_yaml_files(yaml_files)
    return unless yaml_files.empty?

    puts 'エラー: scriptsディレクトリにYAMLファイルが見つかりません'
    puts "YAMLファイルを #{SCRIPTS_DIR} に配置してください"
    exit 1
  end

  def process_yaml_files(yaml_files)
    yaml_files.map do |yaml_file|
      process_single_file(yaml_file)
    end
  end

  def process_single_file(yaml_file)
    basename = File.basename(yaml_file, '.yml')
    output_file = File.join(SLIDES_DIR, "#{basename}.html")

    begin
      presenter = Presenter.new(yaml_file)
      File.write(output_file, presenter.generate_html)
      { file: output_file, status: :success }
    rescue StandardError => e
      { file: yaml_file, status: :error, message: e.message }
    end
  end

  def display_results(results)
    results.each do |result|
      if result[:status] == :success
        puts "生成完了: #{result[:file]}"
      else
        puts "エラー (#{result[:file]}): #{result[:message]}"
      end
    end

    puts "\n全てのプレゼンテーションを生成しました"
    puts 'slidesディレクトリ内のHTMLファイルをブラウザで開いてください'
  end
end
