-- Declare variables for filtering
DECLARE @FilterOrgID INT = NULL; -- Replace NULL with a specific OrgID to filter, or leave it as NULL to not filter by OrgID
DECLARE @FilterStartDate DATE = '2023-09-01'; -- Add this filter to include only consents starting after this date

-- Common Table Expression (CTE) to rank consents by client
WITH RankedConsents AS (
  SELECT
    [HIFIS_Consent].[ClientID], -- Unique identifier for the client
    [HIFIS_Consent].[StartDate], -- Start date of the consent
    [ExpiryDate], -- Expiry date of the consent
    [DocumentID], -- ID of the document associated with the consent (can be NULL)
    [ConsentTypeID], -- Type of consent (e.g., general, specific)
    HIFIS_Organizations.Name AS OrgName, -- Name of the organization managing the consent
    HIFIS_Consent_ServiceProviders.OrgID, -- Organization ID managing the consent

    -- Assign a ranking to each consent per client, sorted by start date and document ID (latest first)
    ROW_NUMBER() OVER (
      PARTITION BY [HIFIS_Consent].[ClientID] -- Group by client
      ORDER BY [HIFIS_Consent].[StartDate] DESC, [DocumentID] DESC -- Rank latest consents higher
    ) AS rn
  FROM 
    [HIFIS_prod].[dbo].[HIFIS_Consent] -- Main consent table
  JOIN 
    HIFIS_Consent_ServiceProviders -- Links consents to service providers
    ON HIFIS_Consent.ConsentID = HIFIS_Consent_ServiceProviders.ConsentID
  JOIN 
    HIFIS_Organizations -- Organization details
    ON HIFIS_Organizations.OrganizationID = HIFIS_Consent_ServiceProviders.OrgID
  JOIN 
    [HIFIS_Clients] -- Client details
    ON [HIFIS_Clients].[ClientID] = [HIFIS_Consent].[ClientID]
  WHERE 
    [HIFIS_Clients].ClientStateTypeId = ## -- Include only active clients
    AND ConsentTypeID IN (#, ##, ###) -- Filter consents by specific types
    AND (@FilterOrgID IS NULL OR HIFIS_Consent_ServiceProviders.OrgID = @FilterOrgID) -- Optional filter by organization
    AND [HIFIS_Consent].[StartDate] > @FilterStartDate -- Filter consents starting after the specified date
)

-- Select the latest consent for each client
SELECT
  [ClientID], -- Client identifier
  [StartDate], -- Start date of the latest consent
  [ExpiryDate], -- Expiry date of the latest consent
  [DocumentID], -- Document ID (if available)
  [ConsentTypeID], -- Type of consent
  OrgName AS [Name] -- Organization managing the consent
FROM 
  RankedConsents
WHERE 
  rn = 1 -- Select only the top-ranked consent for each client
  AND DocumentID IS NULL -- Exclude consents with associated documents
  AND OrgName NOT IN (
    'abc', 
    'xyz'
  ) -- Exclude specific organizations
