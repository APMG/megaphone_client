require "megaphone_client/episode_collection"
require "megaphone_client/episode"
require "megaphone_client/podcast_collection"
require "megaphone_client/podcast"

# @author Jay Arella
module MegaphoneClient
  class ConnectionError < StandardError
  end

  class << self
    attr_accessor :api_base_url, :network_id, :organization_id, :token

    # @option options [String] :api_base_url The api base url includes the domain and `/api` endpoint
    # @option options [String] :network_id The id of the Megaphone network
    # @option options [String] :organization_id The id of the Megaphone organization
    # @option options [String] :token The api token taken from Megaphone's developer settings (https://developers.megaphone.fm/)
    # @return a new instance of MegaphoneClient
    # @example Initialize MegaphoneClient into a variable
    #   megaphone = MegaphoneClient.new({
    #     network_id: '1234',
    #     organization_id: '5678',
    #     token: '910'
    #   })
    #   megaphone #=> new MegaphoneClient

    def new options={}
      @api_base_url = options[:api_base_url] || "https://cms.megaphone.fm/api"
      @network_id = options[:network_id]
      @organization_id = options[:organization_id]
      @token = options[:token]

      self
    end

    # @option options [Symbol] :method  Request method
    # @option options [Hash] :params Request params in a hash
    # @option options [String] :payload If the request method is `POST`, the body of the post
    # @option options [String] :url Request url
    # @note This is a generalized REST method that is used by both the Episode and Podcast class.
    #   If it's successful, it returns a struct representing the data. If it fails, it raises a ConnectionError.
    # @example Get a list of podcasts with #connection
    #   megaphone.connection({
    #     method: :get,
    #     url: "https://cms.megaphone.fm/api/podcasts"
    #   })
    #   #=> Array of structs representing podcasts

    def connection options={}
      request_headers = default_headers.merge({ params: options[:params] })

      begin
        response = RestClient::Request.execute(
          url: options[:url],
          method: options[:method],
          headers: request_headers,
          payload: options[:body].to_json
        )
      rescue RestClient::ExceptionWithResponse => err
        err_msg = assemble_error_message(err)
        raise ConnectionError.new(err_msg)
      end

      JSON.parse(response.body, object_class: OpenStruct)
    end

    # @return a hash with the default request headers, includes the token
    # @example Calling #default_headers after initializing with a token
    #   megaphone = MegaphoneClient.new({
    #     network_id: '1234',
    #     organization_id: '5678',
    #     token: '910'
    #   })
    #   megaphone.default_headers #=> { content_type: "application/json", authorization: "Token token=910", params: {} }

    def default_headers
      {
        content_type: "application/json",
        authorization: "Token token=#{@token}",
        params: {}
      }
    end

    # @return a new instance of MegaphoneClient::EpisodeCollection
    # @example Make a new Episodes instance
    #   megaphone.episodes #=> new MegaphoneClient::EpisodeCollection

    def episodes
      self::EpisodeCollection.new
    end

    # @return a new instance of MegaphoneClient::Podcast
    # @example Make a new Podcast instance
    #   megaphone.podcast("12345") #=> new MegaphoneClient::Podcast with id 12345

    def podcast(id=nil)
      self::Podcast.new(id)
    end

    # @return a new instance of MegaphoneCilent::PodcastCollection
    # @example Make a new Podcasts instance
    #   megaphone.podcasts #=> new MegaphoneClient::PodcastCollection

    def podcasts
      self::PodcastCollection.new
    end

    private

    def assemble_error_message(exception)
      response_error = ''
      begin
        case exception.response.code
        when 400, 403
          response_error = JSON.parse(exception.http_body)['error']
        when 401
          response_error = exception.http_body
        end
      rescue => e
      end
      error_message = "Megaphone ConnectionError: #{exception.response.description}, Request: #{exception.response.request.method} #{exception.response.request.url}"
      error_message += ", Error: #{response_error}" if response_error.present?

      error_message
    end
  end
end
