import cdsapi

c = cdsapi.Client()

# Define the time range
start_year = 1982
end_year = 1982  # Adjust the end year as needed

# Define the area (Global area)
#area = [90, -180, -90, 180]

# Define the variable and format
variable = 'reference_evapotranspiration'
format_type = 'tgz'

# Loop through the years and months
for year in range(start_year, end_year + 1):
    c.retrieve(
        'sis-agrometeorological-indicators',
        {
            'version': '2_0',
            'format': format_type,
            'variable': variable,
            'year': [str(year)],
            'month': [
                '01', '02', '03',
                '04', '05', '06',
                '07', '08', '09',
                '10', '11', '12',
            ],
            'day': [
                '01', '02', '03',
                '04', '05', '06',
                '07', '08', '09',
                '10', '11', '12',
                '13', '14', '15',
                '16', '17', '18',
                '19', '20', '21',
                '22', '23', '24',
                '25', '26', '27',
                '28', '29', '30',
                '31',
            ],
        },
        f'agera5_global_ETo_{year}.tar.gz'
    )