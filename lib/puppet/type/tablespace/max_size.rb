# TODO: Check values
newproperty(:max_size) do
  include SimpleResource
  include SimpleResource::Mungers::Size

  desc "maximum size for autoextending"

  # TODO: Check why it doesn't retirn the right values
  to_translate_to_resource do | raw_resource|
    raw_resource['MAX_SIZE'].to_i
  end

  on_apply do
  	# TODO: include :next for toching. 
  	"#{touch([:autoextend]).join(' ')} maxsize #{should}"
  end

end
