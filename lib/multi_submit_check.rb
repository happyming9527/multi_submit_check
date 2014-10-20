require "multi_submit_check/version"

module MultiSubmitCheck
  class << self
    attr_accessor :store_model, :key_column, :value_column, :only_identity_id
    def configure(&block)
      yield self
    end
  end

  #form表单修改
  module FormHelperHack

    def token_field
      tk = Digest::SHA1.hexdigest((Time.now.to_i + rand(0xffffff)).to_s)[0..20]
      if MultiSubmitCheck.store_model.present?
        MultiSubmitCheck.store_model.where(MultiSubmitCheck.key_column=>request.path,
                                           MultiSubmitCheck.only_identity_id=>session.id).destroy_all
        pair = MultiSubmitCheck.store_model.create(MultiSubmitCheck.key_column=> request.path,
                                                   MultiSubmitCheck.value_column=>tk,
                                                   MultiSubmitCheck.only_identity_id=> session.id)
      end

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
      if  MultiSubmitCheck.store_model.present?
        MultiSubmitCheckStore.transaction do
          key_pair = MultiSubmitCheck.store_model.lock(true).where(only_identity_id: session.id, path: name).last
          key_pair.destroy if key_pair&&key_pair[MultiSubmitCheck.value_column]==params[:__token__]
          return  if key_pair
        end
      else
        if session[name] == params[:__token__]
          session[name] = nil
          return
        end
      end
      render :status => 404, :text => '您提交的请求已经在处理，请勿重复提交表单!' and return
    end

  end

end

module ActionView::Helpers::FormHelper

  #覆写form_tag_in_block方法
  def form_tag_in_block(html_options, &block)
    content = capture(&block)
    output = form_tag_html(html_options)
    if (Rails.configuration.multiple_submit_check rescue false)
      output << token_field   #给form_tag方法添加验证是否重复提交表单的hash串
    end
    output << content
    output.safe_concat("</form>")
  end
end

class ActionController::Base
  include MultiSubmitCheck::ControllerBaseHack
end

module  ApplicationHelper
  include MultiSubmitCheck::FormHelperHack
end