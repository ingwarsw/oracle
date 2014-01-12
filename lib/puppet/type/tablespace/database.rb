newparam(:database) do
  include SimpleResource
  include SimpleResource::Validators::Name
  desc "The database name"
end
