#MiniRails
MiniRails is an MVC framework web server inspired by Ruby on Rails.

#Features

- Renders content and handles redirects
- Protects against double rendering
- Deserializes, reads, and stores JSON cookie data including session data
- Router matches routes and handles bad requests
- Builds methods for GET, PUT, POST, and DELETE patterns.
- Calls HTTP methods with route information

#Using MiniRails
Require the 'controller_base.rb' and 'router.rb' in your server code.

###Using the Controller

Extend the ControllerBase class adding a #go method which calls ControllerBase#render_content or ControllerBase#redirect_to. Example that renders hello page and redirects any request to the hello page:

```ruby
class HelloController < ControllerBase
  def go
    if @req.path == "/hello"
      render_content("Hello, world!", "text/html")
    else
      redirect_to("/hello")
    end
  end
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  HelloController.new(req, res).go
  res.finish
end

Rack::Server.start(
  app: app,
  Port: 3000
)
```


###Using the Router


Pass in a pattern with path, controller, and controller method to the Router#draw method.

```ruby
router = Router.new
router.draw do
  get Regexp.new("^/things$"), Things2Controller, :index
end
```

Call the Router#run(request, response) method passing Rack::Request and Rack::Response objects.

```ruby
app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

Rack::Server.start(
 app: app,
 Port: 3000
)
```


#Planned Features
- ActiveRecord support for object-relational mapping.
- Flash implementation for data in current and next cycle of load
- Rack middleware for error handling with static assets
- Build automated CSRF protection
- PATCH and DELETE request handling
