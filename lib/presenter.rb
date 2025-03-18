require 'yaml'
require 'erb'

class Presenter
  def initialize(yaml_file)
    @data = YAML.load_file(yaml_file)
  end

  def generate_html
    template = File.read(File.join(File.dirname(__FILE__), '../templates/slide.html.erb'))
    erb = ERB.new(template)
    erb.result(binding)
  end

  private

  def title
    @data['title']
  end

  def presenter
    @data['presenter']
  end

  def slides
    @data['slides']
  end
end
