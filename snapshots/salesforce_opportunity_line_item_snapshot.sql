/*
    This snapshot captures changes and deletes of the salesforce opportunity line item table
*/

{% snapshot salesforce_opportunity_line_item_snapshot %}

    {{
        config(
          target_schema='snapshots',
          strategy='timestamp',
          unique_key='id',
          updated_at='system_modstamp',
          invalidate_hard_deletes=True,
        )
    }}

    select * from salesforce.opportunity_line_item

{% endsnapshot %}
