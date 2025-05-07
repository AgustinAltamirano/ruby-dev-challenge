require 'json'

def response(status, body)
  [status, { "Content-Type" => "application/json" }, [body.to_json]]
end