# Database Seeding Guide

## Overview

The `db/seeds.rb` file provides comprehensive, realistic test data for the repair shop management API. It creates a complete working dataset that demonstrates all system capabilities.

## Quick Start

```bash
# Seed the database
rails db:seed

# Reset and seed (WARNING: destroys all data in development)
rails db:reset
```

## What Gets Created

### Users (3)
Three users with different roles to test authorization:

| Role | Email | Password | Name |
|------|-------|----------|------|
| Admin | admin@capetech.com | Admin123! | Admin User |
| Technician | tech@capetech.com | Tech123! | John Tech |
| Cashier | cashier@capetech.com | Cashier123! | Sarah Cash |

### Customers (25)
- Realistic South African names and contact information
- Phone numbers in format: +27XXXXXXXXX
- Mix of customers with email only, phone only, or both
- Some with addresses and ID numbers
- 22 active, 3 inactive customers

### Devices (40)
Distribution by type:
- **Phones (20)**: Samsung, Apple, Huawei, Xiaomi, Nokia
- **Tablets (8)**: Apple, Samsung, Huawei, Lenovo
- **Laptops (8)**: HP, Dell, Lenovo, Apple, Asus
- **Desktops (2)**: Dell, HP, Lenovo, Custom Build
- **Other (2)**: Various devices

Each device includes:
- Realistic brand and model combinations
- Serial numbers (60% of devices)
- IMEI numbers (70% of phones)
- Optional password/PIN
- Customer ownership

### Repair Tickets (60)

**Status Distribution:**
- Pending: 6 (10%)
- In Progress: 12 (20%)
- Waiting for Parts: 9 (15%)
- Completed: 18 (30%)
- Collected: 12 (20%)
- Cancelled: 3 (5%)

**Priority Distribution:**
- Urgent: 6 (10%)
- High: 12 (20%)
- Medium: 30 (50%)
- Low: 20 (20%)

**Features:**
- 30 different realistic fault descriptions
- Random accessories (charger, case, earphones, etc.)
- Estimated costs: R100 - R2,000
- Actual costs for completed/collected tickets
- Technician assignments for active tickets
- Timestamps spanning last 30 days
- Proper completion and collection dates

### Repair Statuses (150+)

Each ticket has 2-5 status changes showing realistic progression:
- Pending → In Progress → Completed → Collected
- Pending → In Progress → Waiting for Parts → Completed → Collected
- Pending → Cancelled

Each status includes:
- Appropriate user (technician or admin)
- Realistic notes describing the action
- Chronological timestamps

### Payments (50+)

**Payment Methods:**
- Cash: 40%
- Card: 40%
- Bank Transfer: 15%
- Other: 5%

**Payment Patterns:**
- 70% fully paid in one transaction
- 30% partially paid (2-3 payments)
- Reference numbers for card and bank transfers
- Payment dates close to completion dates
- Received by cashier or admin

### Activity Logs (200+)

Comprehensive audit trail including:
- **Ticket Created**: When tickets are first created
- **Status Updated**: Every status change
- **Ticket Assigned**: When technician is assigned
- **Payment Received**: All payment transactions
- **Note Added**: Random customer interactions

Each log includes:
- User who performed the action
- Descriptive text
- Related repair ticket
- Metadata in JSONB format

## Data Characteristics

### Realism
- South African phone numbers (+27...)
- South African ID numbers
- Realistic device brands and models
- Common repair faults
- Proper date progressions
- Logical status flows

### Variety
- Mix of device types and brands
- Different customer demographics
- Various ticket statuses and priorities
- Multiple payment methods
- Different fault types

### Relationships
- Customers can have multiple devices
- Devices can have multiple repair tickets
- Tickets have proper status progression
- Payments linked to completed tickets
- Activity logs track all major events

## Safety Features

### Environment Check
The seed file only clears existing data in development:

```ruby
if Rails.env.development?
  # Clear data
end
```

### Transaction Wrapper
All seed operations are wrapped in a transaction:

```ruby
ActiveRecord::Base.transaction do
  # Seed operations
end
```

If any error occurs, all changes are rolled back.

### Error Handling
Comprehensive error handling with helpful messages:

```ruby
rescue StandardError => e
  puts "❌ Error seeding database: #{e.message}"
  raise
end
```

## Expected Output

When running `rails db:seed`, you'll see:

```
🌱 Seeding database...
🧹 Clearing existing data...
✓ Existing data cleared
✓ Creating users... (3 created)
✓ Creating customers... (25 created)
✓ Creating devices... (40 created)
✓ Creating repair tickets... (60 created)
✓ Creating repair statuses... (156 created)
✓ Creating payments... (52 created)
✓ Creating activity logs... (218 created)

🎉 Database seeded successfully!

📊 Summary:
- Users: 3 (1 admin, 1 technician, 1 cashier)
- Customers: 25 (22 active, 3 inactive)
- Devices: 40
  - Phones: 20
  - Tablets: 8
  - Laptops: 8
  - Desktops: 2
  - Other: 2
- Repair Tickets: 60
  - Pending: 6
  - In Progress: 12
  - Waiting for Parts: 9
  - Completed: 18
  - Collected: 12
  - Cancelled: 3
- Repair Statuses: 156
- Payments: 52
  - Total Amount: R45,280.00
  - Cash: 21
  - Card: 21
  - Bank Transfer: 8
  - Other: 2
- Activity Logs: 218

✨ Ready to use!
```

## Use Cases

### Testing Authentication
Use the three seeded users to test different authorization levels:
- Admin can access everything
- Technician can update tickets and statuses
- Cashier can process payments

### Testing Workflows
The seed data includes tickets in all states:
- Test ticket creation and assignment
- Test status progression
- Test payment processing
- Test ticket completion and collection
- Test cancellations

### Testing Reports
With 60 tickets and 50+ payments:
- Generate financial reports
- Analyze technician performance
- Track ticket completion rates
- Monitor payment methods

### Testing Search and Filters
- Search by customer name or phone
- Filter tickets by status or priority
- Find devices by type or brand
- Filter payments by method or date range

## Customization

To modify the seed data:

1. **Change quantities**: Update the distribution arrays
2. **Add device types**: Extend `DEVICE_BRANDS` and model hashes
3. **Add fault types**: Extend `FAULT_DESCRIPTIONS` array
4. **Adjust date range**: Change `rand(30).days.ago` to your preference
5. **Modify distributions**: Adjust the distribution hashes

## Dependencies

The seed file requires:
- **Faker gem**: For generating realistic data
- **Rails environment**: Must be run in Rails context
- **Database**: PostgreSQL with schema loaded

## Troubleshooting

### Faker Not Found
```bash
bundle install
```

### Database Not Created
```bash
rails db:create db:migrate
```

### Permission Errors
Ensure your database user has CREATE/DELETE permissions.

### Validation Errors
Check the error message for specific validation failures. The seed file uses valid data, but schema changes may cause issues.

## Performance

Seeding typically completes in:
- **Development**: 5-15 seconds
- **Test**: 3-8 seconds

The transaction wrapper ensures atomicity but may be slower on some systems.

## Best Practices

1. **Run in development only**: Never run on production
2. **Backup before seeding**: Although seeds clear data only in development
3. **Test after seeding**: Verify data integrity
4. **Customize as needed**: Adapt to your specific needs
5. **Keep up to date**: Update seeds when schema changes

## Related Documentation

- [Schema Documentation](../db/schema.rb)
- [Model Documentation](../app/models/)
- [API Documentation](./API.md)
- [Setup Guide](../SETUP.md)
