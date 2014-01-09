require 'utils/oracle_access'

Puppet::Type.type(:database).provide(:oracle11) do
	include Utils::OracleAccess

  desc "Create a Database via regular SQL"

  def self.instances
    []
  end

  def create
  	# sql "create database #{resource[:name]}", on: resource[:sid]
  end

  def destroy
  	# sql "drop database #{resource[:name]}", on: resource[:sid]
  end

  def exists?
  	# sql "select name from dba_databases where name = #{resource[:name]}", on: resource[:sid]
  end

  def maxinstances
  	# TODO: Get the value of maxinstances
  end

  def maxinstances=(value)
  	# sql "alter database #{resource[:name]} set maxinstances #{value}"
  end

  def maxdatafiles
  	# TODO: Get the value of maxinstances
  end

  def maxdatafiles=(value)
  	# sql "alter database #{resource[:name]} set maxdatafiles #{value}"
  end


end