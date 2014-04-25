require "multi_submit_check/version"

module MultiSubmitCheck

  #form表单修改
  module FormHelperHack

    def form_tag_in_block(html_options, &block)
      content = capture(&block)
      output = ActiveSupport::SafeBuffer.new
      output.safe_concat(form_tag_html(html_options))
      output<<token_field #给form_tag方法添加验证是否重复提交表单的hash串
      output << content
      output.safe_concat("</form>")
    end

    def token_field
      tk = Digest::SHA1.hexdigest((Time.now.to_i + rand(0xffffff)).to_s)[0..20]
      #生成session的名字和当前请求路径一样。
      return hidden_field_tag(:__token__, (session[request.path] = tk))
    end

  end

  #控制器修改
  module ControllerBaseHack

    def self.included(base)
      base.send :before_filter, :__multiple_submit_check__
    end

    def __multiple_submit_check__
      if request.post?
        render :text => __check_token__ and return if __check_token__.present?
      end
    end

    #每个action只能打开一个表单,否则session会有冲突.
    def __check_token__
      return if params[:__token__].blank?
      name=URI.parse(request.referrer).path
      if session[name] == params[:__token__]
        session[name] = nil
        return
      end
      render :status => 404, :text => '您提交的请求已经在处理，请勿重复提交表单!' and return
    end

  end

end

module ActionView::Helpers::FormHelper
  include MultiSubmitCheck::FormHelperHack
end

class ActionController::Base
  include MultiSubmitCheck::ControllerBaseHack
end