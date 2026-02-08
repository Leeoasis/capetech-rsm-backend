# Repair Shop Management System - Database Models

This document summarizes all the database models created for the repair shop management system.

## Models Created

### 1. User Model
**File**: `app/models/user.rb`  
**Migration**: `db/migrate/*_create_users.rb`

**Fields**:
- `email` (string) - unique, indexed
- `password_digest` (string) - for has_secure_password
- `first_name` (string)
- `last_name` (string)
- `role` (integer) - enum: admin(0), technician(1), cashier(2)
- `active` (boolean) - default: true

**Validations**:
- Email: presence, uniqueness, valid email format
- Password: presence on create, minimum 8 characters
- First name: presence
- Last name: presence
- Role: presence

**Associations**:
- `has_many :repair_tickets` (as assigned_technician)
- `has_many :activity_logs`

**Methods**:
- `full_name` - returns "first_name last_name"

---

### 2. Customer Model
**File**: `app/models/customer.rb`  
**Migration**: `db/migrate/*_create_customers.rb`

**Fields**:
- `first_name` (string)
- `last_name` (string)
- `email` (string) - indexed
- `phone` (string) - indexed
- `address` (text)
- `id_number` (string)
- `active` (boolean) - default: true
- `deleted_at` (datetime) - indexed, for soft delete

**Validations**:
- First name: presence
- Last name: presence
- Email: valid format (if present)
- Phone: valid format (if present)
- Custom: at least one of email or phone must be present

**Associations**:
- `has_many :devices`
- `has_many :repair_tickets`

**Scopes**:
- `active` - returns active customers only
- `with_deleted` - returns all customers including soft deleted
- `by_name_or_phone(search)` - searches by name or phone

**Soft Delete**: 
- Uses `deleted_at` field
- Default scope excludes deleted records
- `soft_delete` method to mark as deleted

---

### 3. Device Model
**File**: `app/models/device.rb`  
**Migration**: `db/migrate/*_create_devices.rb`

**Fields**:
- `customer_id` (references) - foreign key, indexed
- `device_type` (integer) - enum: phone(0), tablet(1), laptop(2), desktop(3), other(4), indexed
- `brand` (string)
- `model` (string)
- `serial_number` (string) - indexed
- `imei` (string) - indexed
- `password_pin` (string)
- `notes` (text)
- `deleted_at` (datetime) - indexed, for soft delete

**Validations**:
- Device type: presence
- Brand: presence
- Model: presence
- Customer ID: presence

**Associations**:
- `belongs_to :customer`
- `has_many :repair_tickets`

**Scopes**:
- `by_device_type(type)` - filters by device type
- `by_customer(customer_id)` - filters by customer

**Soft Delete**: 
- Uses `deleted_at` field
- Default scope excludes deleted records
- `soft_delete` method to mark as deleted

---

### 4. RepairTicket Model
**File**: `app/models/repair_ticket.rb`  
**Migration**: `db/migrate/*_create_repair_tickets.rb`

**Fields**:
- `ticket_number` (string) - unique, indexed, auto-generated
- `device_id` (references) - foreign key, indexed
- `customer_id` (references) - foreign key, indexed
- `assigned_technician_id` (integer) - foreign key to users, indexed
- `fault_description` (text)
- `accessories_received` (text)
- `estimated_cost` (decimal 10,2)
- `actual_cost` (decimal 10,2)
- `status` (integer) - enum: pending(0), in_progress(1), waiting_for_parts(2), completed(3), collected(4), cancelled(5), indexed
- `priority` (integer) - enum: low(0), medium(1), high(2), urgent(3), indexed
- `completed_at` (datetime)
- `collected_at` (datetime)
- Timestamps: `created_at`, `updated_at` (created_at indexed)

**Validations**:
- Ticket number: uniqueness
- Fault description: presence
- Status: presence
- Priority: presence
- Customer ID: presence
- Device ID: presence

**Associations**:
- `belongs_to :device`
- `belongs_to :customer`
- `belongs_to :assigned_technician` (User, optional)
- `has_many :repair_statuses`
- `has_many :payments`
- `has_many :activity_logs`

**Scopes**:
- `by_status(status)` - filters by status
- `by_technician(technician_id)` - filters by assigned technician
- `by_priority(priority)` - filters by priority
- `pending` - returns pending tickets
- `in_progress` - returns in-progress tickets
- `completed` - returns completed tickets
- `uncollected` - returns completed but not collected tickets
- `recent` - orders by created_at desc

**Callbacks**:
- `before_create :generate_ticket_number` - auto-generates ticket number (format: RT{YYYYMMDD}{8-char-hex})

---

### 5. RepairStatus Model
**File**: `app/models/repair_status.rb`  
**Migration**: `db/migrate/*_create_repair_statuses.rb`

**Fields**:
- `repair_ticket_id` (references) - foreign key, indexed
- `status` (integer) - enum: same as RepairTicket
- `notes` (text)
- `changed_by_user_id` (integer) - foreign key to users
- Timestamps: `created_at`, `updated_at` (created_at indexed)

**Validations**:
- Status: presence
- Repair ticket ID: presence

**Associations**:
- `belongs_to :repair_ticket`
- `belongs_to :changed_by` (User, optional)

---

### 6. Payment Model
**File**: `app/models/payment.rb`  
**Migration**: `db/migrate/*_create_payments.rb`

**Fields**:
- `repair_ticket_id` (references) - foreign key, indexed
- `amount` (decimal 10,2)
- `payment_method` (integer) - enum: cash(0), card(1), bank_transfer(2), other(3), indexed
- `payment_date` (datetime) - indexed
- `reference_number` (string)
- `notes` (text)
- `received_by_user_id` (integer) - foreign key to users
- Timestamps: `created_at`, `updated_at`

**Validations**:
- Amount: presence, greater than 0
- Payment method: presence
- Repair ticket ID: presence
- Payment date: presence

**Associations**:
- `belongs_to :repair_ticket`
- `belongs_to :received_by` (User, optional)

**Scopes**:
- `by_date_range(start_date, end_date)` - filters by payment date range
- `by_method(method)` - filters by payment method
- `total_collected` - returns sum of all payment amounts

---

### 7. ActivityLog Model
**File**: `app/models/activity_log.rb`  
**Migration**: `db/migrate/*_create_activity_logs.rb`

**Fields**:
- `repair_ticket_id` (integer) - indexed, optional
- `user_id` (references) - foreign key, indexed
- `action_type` (string) - indexed
- `description` (text)
- `metadata` (jsonb) - for storing additional structured data
- Timestamps: `created_at`, `updated_at` (created_at indexed)

**Validations**:
- Action type: presence
- Description: presence
- User ID: presence

**Associations**:
- `belongs_to :repair_ticket` (optional)
- `belongs_to :user`

---

## Database Schema

All migrations have been executed successfully. The schema includes:

- Proper indexes on foreign keys and frequently queried fields
- Foreign key constraints for referential integrity
- Default values where specified
- Unique constraints on critical fields (email, ticket_number)
- Support for JSONB data type (metadata field)

## Testing Summary

All models have been tested and verified:

✅ Model creation and validations  
✅ Associations (belongs_to, has_many)  
✅ Enums (role, device_type, status, priority, payment_method)  
✅ Scopes (filtering and querying)  
✅ Soft delete functionality  
✅ Auto-generation of ticket numbers  
✅ Password security (has_secure_password)  
✅ Email format validation  
✅ Custom validations (email or phone required)  
✅ Uniqueness constraints  
✅ Numericality validations

## Next Steps

The database foundation is now complete. You can proceed with:

1. Creating controllers and API endpoints
2. Implementing authentication and authorization
3. Adding business logic services
4. Creating comprehensive test suites
5. Building the frontend interface
