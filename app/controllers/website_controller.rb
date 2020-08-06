class WebsiteController < ApplicationController
  before_action :check_token, :check_amount, :set_charity, only: :donate

  def index
    @token = nil
  end

  def donate
    charge = Omise::Charge.create({
      amount: (params[:amount].to_f * 100).to_i,
      currency: "THB",
      card: params[:omise_token],
      description: "Donation to #{@charity.name} [#{@charity.id}]",
    })

    if charge.paid
      @charity.credit_amount(charge.amount)
      flash.notice = t(".success")
      redirect_to root_path
    else
      failure_procedure
    end
  end

  private

  def check_token
    failure_procedure unless params[:omise_token].present?

    @token = Omise::Token.retrieve(params[:omise_token])
  end

  def check_amount
    failure_procedure if params[:amount].blank? || params[:amount].to_i <= 20
  end

  def set_charity
    return @charity = Charity.all.sample if params[:charity] == "random"

    @charity = Charity.find_by(id: params[:charity])
    failure_procedure unless @charity
  end

  def failure_procedure
    flash.now.alert = t(".failure")
    render :index
  end
end
