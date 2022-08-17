/*
    This snapshot captures changes and deletes of the salesforce contact table
*/

{% snapshot salesforce_contact_snapshot %}

    {{
        config(
          target_schema='snapshots',
          strategy='timestamp',
          unique_key='id',
          updated_at='system_modstamp',
          invalidate_hard_deletes=True,
        )
    }}

    select * from salesforce.contact

{% endsnapshot %}
