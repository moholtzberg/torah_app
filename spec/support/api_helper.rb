module ApiHelper

  def api_sign_in(user)
    sign_in(user)
    request.headers.merge!(user.create_new_auth_token)
  end

  def json_for(resource, options={})
    return serialized(resource, serializer: options[:serializer]) if resource.is_a?(ActiveRecord::Base)
    resource.map do |el|
      serialized(el, serializer: options[:serializer])
    end
  end

  def json_response
      return if response.body == "null"
        @json_response ||= JSON.parse(response.body, symbolize_names: true)
  end

  def serialized(resource, options={})
    serializer = options[:serializer] || Object.const_get("#{resource.class.to_s}Serializer")
    ActiveModelSerializers::SerializableResource.new(
      resource, serializer: serializer).as_json
  end
end
