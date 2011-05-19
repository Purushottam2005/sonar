#
# Sonar, entreprise quality control tool.
# Copyright (C) 2008-2011 SonarSource
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
class SettingsController < ApplicationController

  SECTION=Navigation::SECTION_CONFIGURATION

  verify :method => :post, :only => ['update'], :redirect_to => { :action => :index }

  def index
    return access_denied unless is_admin?  
  end

  def update
    if params[:resource_id]
      project=Project.by_key(params[:resource_id])
      return access_denied unless is_admin?(project)
      resource_id=project.id
    else
      return access_denied unless is_admin?
    end

    plugins = java_facade.getPluginsMetadata()
    plugins.each do |plugin|
      properties=java_facade.getPluginProperties(plugin)
      properties.each do |property|
        value=params[property.key()]
        persisted_property = Property.find(:first, :conditions => {:prop_key=> property.key(), :resource_id => resource_id, :user_id => nil})

        if persisted_property
          if value.empty?
            Property.delete_all('prop_key' => property.key(), 'resource_id' => resource_id, 'user_id' => nil)
          elsif persisted_property.text_value != value.to_s
            persisted_property.text_value = value.to_s
            persisted_property.save
          end
        elsif !value.blank? 
          Property.create(:prop_key => property.key(), :text_value => value.to_s, :resource_id => resource_id)
        end
      end
    end
    java_facade.reloadConfiguration()

    flash[:notice] = 'Parameters updated.'
    if resource_id
      redirect_to :controller => 'project', :action => 'settings', :id => resource_id
    else
      redirect_to :action => 'index'
    end
  end
end
