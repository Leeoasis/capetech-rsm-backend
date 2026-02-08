# Pundit Quick Reference Guide

## Basic Usage

### In Controllers

```ruby
# Check authorization (automatically uses action name)
authorize @repair_ticket  # Calls RepairTicketPolicy#update? for update action

# Check specific action
authorize @repair_ticket, :update_status?

# Scope collections
@tickets = policy_scope(RepairTicket)

# Check permission without raising error
if policy(@repair_ticket).update?
  # do something
end
```

### Skip Authorization

```ruby
class SomeController < ApplicationController
  def skip_authorization?
    true  # or conditionally skip
  end
end
```

## Policy Helpers

### In Policies

```ruby
class MyPolicy < ApplicationPolicy
  def update?
    # user is the current_user
    # record is the resource being authorized
    user.admin? || record.owner_id == user.id
  end
end
```

### Policy Scope

```ruby
class MyPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end
end
```

## Role Checks

```ruby
user.admin?      # Check if user is admin
user.technician? # Check if user is technician  
user.cashier?    # Check if user is cashier
```

## Common Patterns

### Admin Override

```ruby
def update?
  return true if user&.admin?
  # other checks...
end
```

### Owner Check

```ruby
def update?
  user&.admin? || record.user_id == user.id
end
```

### Association Check

```ruby
def update?
  user&.admin? || record.assigned_technician_id == user.id
end
```

## Testing Policies

```ruby
require 'rails_helper'

RSpec.describe MyPolicy do
  subject { described_class }

  let(:admin) { create(:user, role: :admin) }
  let(:resource) { create(:my_resource) }

  permissions :update? do
    it "grants access to admin" do
      expect(subject).to permit(admin, resource)
    end

    it "denies access to regular user" do
      expect(subject).not_to permit(user, resource)
    end
  end
end
```

## Error Responses

### 403 Forbidden
When `Pundit::NotAuthorizedError` is raised:
```json
{
  "error": {
    "message": "You are not authorized to perform this action",
    "details": {}
  }
}
```

## Best Practices

1. **Always authorize**: Use `after_action :verify_authorized` to ensure authorization is checked
2. **Use policy scopes**: Filter collections in index actions with `policy_scope`
3. **Keep policies simple**: Complex logic should be in services or models
4. **Test thoroughly**: Write tests for all permission scenarios
5. **Admin override**: Always check `user&.admin?` first for convenience
