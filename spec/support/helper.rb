module Helper
  def create_memberships_for user
    10.times do
      organization = FactoryGirl.create(:organization)
      organization.memberships.create(user_id: user.id, confirmed_at: Time.current)
    end
    user.memberships
  end

  def create_chatroom_for(user_a, user_b)
    chatroom = Chatroom.create
    chatroom.add_participant(user_a)
    chatroom.add_participant(user_b)
    chatroom
  end
end
