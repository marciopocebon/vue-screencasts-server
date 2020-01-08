Stripe.api_key = 'sk_test_Hps7yIGXMTwzBFh9pTsci6wy'

class Api::StripeController < ApplicationController
  def create_subscription
    source = params['source']
    planId = params['planId']

    user = current_user

    if(user.stripe_id)
      customer = Stripe::Customer.retrieve(user.stripe_id)
    end

    if !customer
      customer = Stripe::Customer.create({
        email: user.email,
        name: user.name,
        source: source['id'],
        metadata: {
          app_id: user.id
        }
      })

      user.stripe_id = customer.id
      user.save
    end

    # TODO: test what happens when it's called multiple times on one user
    # Desired behavior is to cancel the old subscription and create a new one

    subscription = Stripe::Subscription.create({
      customer: customer.id,
      items: [{plan: planId}]
    })

    user.subscription_id = subscription.id
    user.save

    render json: UserSerializer.new(user).serializable_hash
  end

  def user_info
    customer_id = current_user.stripe_id 
    if(!customer_id)
      head 400
    end

    customer = Stripe::Customer.retrieve(customer_id)
    subscription = Stripe::Subscription.retrieve(current_user.subscription_id)
    card = Stripe::Customer.retrieve_source(customer_id, subscription.default_payment_method)
    charges = Stripe::Charge.list({customer: customer_id})
    
    
    render json: {
      charges: charges.data,
      card: card.data,
      subscription: subscription,
      customer: customer
    }
  end
end