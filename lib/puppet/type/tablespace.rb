require 'simple_resource'
require 'utils/oracle_access'

module Puppet
  newtype(:tablespace) do
    include SimpleResource
    include Utils::OracleAccess

    desc "This resource allows you to manage an Oracle tablespace."

    set_command(:sql)

    ensurable

    on_create do
      "create #{ts_type} tablespace \"#{name}\""
    end

    on_modify do
      "alter tablespace \"#{name}\""
    end

    on_destroy do
      "drop tablespace \"#{name}\" including contents and datafiles"
    end

    to_get_raw_resources do
      sql "select * from dba_tablespaces t, dba_data_files f where t.TABLESPACE_NAME = f.TABLESPACE_NAME"
    end

    parameter :name
    parameter :database
    property :logging
    property :datafile
    property :size
    property :autoextend
    property :next
    property :max_size
    property :extent_management
    property :segment_space_management
    property :bigfile


    def ts_type
      if self['bigfile'] == :yes
        'bigfile'
      else
        'smallfile'
      end
    end


  end
end
