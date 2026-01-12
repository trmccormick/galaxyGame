require 'ollama-ai'
require 'json'
require 'fileutils'

module Generators
  class GameDataGenerator
    DEFAULT_LLM_HOST = 'http://localhost:11434'
    DEFAULT_MODEL = 'llama3'

    def initialize(model = DEFAULT_MODEL)
    @host = ENV['LLM_HOST_URL'] || DEFAULT_LLM_HOST
    @model = model
    @client = Ollama.new(
      credentials: { address: @host },
      options: { server_sent_events: false }
    )
  end

  def generate_item(template_path, output_path, params = {})
    template = load_template(template_path)
    json_content = generate_content_with_retry(template, params)
    save_content(json_content, output_path)
    JSON.parse(json_content)
  end

  def batch_generate(template_path, specs)
    specs.map do |spec|
      output_path = spec.delete(:output_path)
      generate_item(template_path, output_path, spec)
    end
  end

  private

  def load_template(template_path)
    JSON.parse(File.read(template_path))
  rescue JSON::ParserError => e
    raise "Invalid JSON in template file: #{e.message}"
  rescue Errno::ENOENT
    raise "Template file not found: #{template_path}"
  end

  def generate_content(template, params)
    prompt = build_prompt(template, params)
    result = @client.generate(
      model: @model,
      prompt: prompt,
      options: { temperature: 0.1, max_tokens: 2048 },
      stream: false
    )
    extract_json(result['response'])
  rescue => e
    raise "Ollama API error: #{e.class} - #{e.message}"
  end

  def generate_content_with_retry(template, params, max_retries = 3)
    retries = 0
    begin
      generate_content(template, params)
    rescue => e
      retries += 1
      if retries <= max_retries
        sleep 2
        retry
      else
        raise e
      end
    end
  end

  def build_prompt(template, params)
    template_str = JSON.pretty_generate(template)
    version = template.dig('metadata', 'version') || 'unknown'
    <<~PROMPT
      You are a JSON data generator for a space exploration game. Please follow version #{version} of this schema.
      Ensure compliance with the structure and style in the template below.

      Template:
      ```json
      #{template_str}
      ```

      Parameters to apply:
      #{params.map { |k, v| "- #{k}: #{v}" }.join("\n")}

      Respond ONLY with a complete JSON object that is valid and conforms to the provided structure.
    PROMPT
  end

  def extract_json(response_text)
    # Try to parse the response as JSON, or extract the first JSON object found
    begin
      full_response = JSON.parse(response_text)
      if full_response.is_a?(Hash) && full_response.key?("response")
        json_string = full_response["response"].to_s
        json_string = json_string.gsub('\\n', "\n").gsub('\\"', '"')
        if json_string.include?('{') && json_string.include?('}')
          json_start = json_string.index('{')
          json_end = json_string.rindex('}') + 1
          json_string = json_string[json_start...json_end]
        end
        JSON.parse(json_string)
        return json_string
      else
        return response_text
      end
    rescue JSON::ParserError
      if response_text.include?('{') && response_text.include?('}')
        json_start = response_text.index('{')
        json_end = response_text.rindex('}') + 1
        json_string = response_text[json_start...json_end]
        JSON.parse(json_string)
        return json_string
      else
        raise "Failed to extract valid JSON"
      end
    end
  end

  def save_content(content, output_path)
    dir = File.dirname(output_path)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    File.write(output_path, JSON.pretty_generate(JSON.parse(content)))
  rescue => e
    raise "Failed to save content: #{e.message}"
  end
  end
end