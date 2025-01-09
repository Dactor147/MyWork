-- Calculate the number of clients housed within the specified time period
SELECT 
    COUNT(hch.clientid) AS NumberOfPeopleHoused -- Count the number of unique clients housed
FROM 
    [HIFIS_prod].[dbo].[HIFIS_Clients_HousePlacements] hch -- Table linking clients to house placements

-- Join to house placements table to get the move-in dates
JOIN 
    [HIFIS_prod].[dbo].[HIFIS_HousePlacements] hp 
    ON hch.ClientHousePlacementID = hp.HousePlacementID

-- Join to clients table to link to individual clients
JOIN 
    [HIFIS_prod].[dbo].[HIFIS_Clients] hc 
    ON hch.ClientID = hc.ClientID 

-- Join to people table to retrieve cluster information
JOIN 
    [HIFIS_prod].[dbo].[HIFIS_People] p 
    ON p.PersonID = hc.PersonID

-- Apply filters to limit data to the specified date range and cluster
WHERE 
    hp.MovedInDate >= '2022-04-01' -- Include records with a move-in date on or after April 1, 2022
    AND hp.MovedInDate <= '2023-03-31' -- Include records with a move-in date on or before March 31, 2023
    AND ClusterID = ## -- Include only records where the cluster ID is ##
