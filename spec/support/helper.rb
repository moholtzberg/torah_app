module Helper
  def json_response
      return if response.body == "null"
        @json_response ||= JSON.parse(response.body, symbolize_names: true)
  end

end
