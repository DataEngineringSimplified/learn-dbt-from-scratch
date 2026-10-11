{# Convert leave days to hours assuming an 8-hour workday. #}
{% macro days_to_hours(days_column) %}
    ({{ days_column }} * 8)
{% endmacro %}
