# frozen_string_literal: true

require 'puppeteer-ruby'
require 'fileutils'
require 'combine_pdf'

# HTMLファイルからPDFを生成するクラス
class PdfGenerator
  SLIDES_DIR = File.join(File.dirname(__FILE__), '../slides')
  PDF_DIR = File.join(File.dirname(__FILE__), '../pdf')

  def initialize
    FileUtils.mkdir_p(PDF_DIR)
  end

  def generate_all
    html_files = find_html_files
    validate_html_files(html_files)

    results = process_html_files(html_files)
    display_results(results)
  end

  private

  def find_html_files
    Dir.glob(File.join(SLIDES_DIR, '*.html'))
  end

  def validate_html_files(html_files)
    return unless html_files.empty?

    puts 'エラー: slidesディレクトリにHTMLファイルが見つかりません'
    puts '先に bin/present を実行してHTMLファイルを生成してください'
    exit 1
  end

  def process_html_files(html_files)
    html_files.map do |html_file|
      process_single_file(html_file)
    end
  end

  def process_single_file(html_file)
    basename = File.basename(html_file, '.html')
    output_file = File.join(PDF_DIR, "#{basename}.pdf")
    temp_dir = File.join(PDF_DIR, 'temp')
    FileUtils.mkdir_p(temp_dir)

    begin
      Puppeteer.launch(headless: true) do |browser|
        page = browser.new_page
        page.goto("file://#{File.expand_path(html_file)}")

        # スライド数を取得
        slide_count = page.evaluate('document.querySelectorAll(".slide").length')
        pdf_files = []

        # 各スライドをPDFとして保存
        slide_count.times do |i|
          temp_pdf = File.join(temp_dir, "slide_#{i}.pdf")
          page.evaluate("showSlide(#{i})")
          # ページの描画が完了するまで待機
          sleep 0.5
          page.pdf(
            path: temp_pdf,
            format: 'A4',
            landscape: true,
            print_background: true,
            display_header_footer: false
          )
          pdf_files << temp_pdf
        end

        # PDFを結合
        merge_pdfs(pdf_files, output_file)
      end

      # 一時ファイルを削除
      FileUtils.rm_rf(temp_dir)
      { file: output_file, status: :success }
    rescue StandardError => e
      # エラー時も一時ファイルを削除
      FileUtils.rm_rf(temp_dir)
      { file: html_file, status: :error, message: e.message }
    end
  end

  def merge_pdfs(pdf_files, output_file)
    pdf = CombinePDF.new
    pdf_files.each do |file|
      pdf << CombinePDF.load(file)
    end
    pdf.save output_file
  end

  def display_results(results)
    results.each do |result|
      if result[:status] == :success
        puts "PDF生成完了: #{result[:file]}"
      else
        puts "エラー (#{result[:file]}): #{result[:message]}"
      end
    end

    puts "\n全てのPDFを生成しました"
    puts 'pdfディレクトリ内のファイルを確認してください'
  end
end
