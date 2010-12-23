class ErpApp::Desktop::BaseController < ErpApp::ApplicationController
  before_filter :login_required

  def login_path
    return desktop_login_path
  end

  def index
    @user     = current_user
    @desktop  = ::Desktop.find_by_user(@user)
  end

  protected
  
  def build_ext_tree(node_hashes)
    ext_json = '['

    node_hashes.each do |node_hash|
      ext_json << build_node(node_hash)
    end

    ext_json = remove_last_comma(ext_json)

    ext_json += ']'

    ext_json
  end

  private
  
  def build_node(node_hash)
    ext_json = "{text:'#{node_hash[:text]}', id:#{node_hash[:id]}, "

    unless node_hash[:icon_cls].blank?
      ext_json << "iconCls: \"#{node_hash[:icon_cls]}\","
    end

    if node_hash[:children].blank?
      ext_json << "leaf:true},"
    else
      ext_json << "children:["
      node_hash[:children].each do |child_node|
        ext_json << build_node(child_node)
      end
      ext_json = remove_last_comma(ext_json)
      ext_json << "]},"
    end

    ext_json
  end

  def remove_last_comma(ext_json)
    ext_json = ext_json[0...ext_json.length - 1] if ext_json.split('').last == ','
    ext_json
  end

end
