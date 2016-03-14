require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params, :session

  # Setup the controller
  def initialize(req, res, route_params = {})

    @req = req
    @res = res
    @params = route_params.merge(req.params)
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    if already_built_response?
      raise ("Double render!")
    else
      @already_built_response = true
      @res.status = 302
      @res.header["location"] = url
      session.store_session(@res)
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    if already_built_response?
      raise("Dobule render on response!")
    else
      @res.write(content)
      @res['Content-Type'] = content_type
      @already_built_response = true
      session.store_session(@res)
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    if already_built_response?
      raise("Dobule render on response!")
    else
      controller_name = self.class.to_s
      controller_name.slice!(-10, 10)
      controller = controller_name << "_controller"
      content_type = 'text/html'
      raw = File.read("views/#{controller}/#{template_name}.html.erb")
      content = ERB.new(raw).result(binding)

      render_content(content, content_type)
    end
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
  end
end
