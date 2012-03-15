#
# Sonar, entreprise quality control tool.
# Copyright (C) 2008-2012 SonarSource
# mailto:contact AT sonarsource DOT com
#
# Sonar is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.
#
# Sonar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with Sonar; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02
#
class EncryptionConfigurationController < ApplicationController

  SECTION=Navigation::SECTION_CONFIGURATION
  before_filter :admin_required
  before_filter :remove_layout

  verify :method => :post, :only => [:generate_secret, :encrypt], :redirect_to => {:action => :index}

  def index
    if java_facade.hasSecretKey()
      render :action => 'index'
    else
      render :action => 'generate_secret_form'
    end
  end

  def generate_secret_form

  end

  def generate_secret
    render :text => java_facade.generateRandomSecretKey()
  end

  def encrypt
    bad_request('No secret key') unless java_facade.hasSecretKey()
    render :text => java_facade.encrypt(params[:text])
  end

  private

  def remove_layout
    params[:layout]='false'
  end
end