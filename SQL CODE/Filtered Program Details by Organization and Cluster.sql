SELECT        
    HIFIS_Programs.Name AS "PROG NAME", -- Name of the program
    HIFIS_Organizations.Name AS "ORG NAME", -- Name of the organization offering the program
    HIFIS_Programs.ProgramDateStart AS "PROG START DATE", -- Start date of the program
    HIFIS_Programs.ProgramDateEnd AS "PROG END DATE", -- End date of the program
    HIFIS_Programs.CreatedDate AS "PROG CREATION DATE", -- Date the program was created
    HIFIS_Programs.ActiveYN AS "PROG ACTIVE Y/N", -- Whether the program is active (Yes/No)
    HIFIS_Programs.Comments AS "COMMENTS", -- Additional comments about the program
    HIFIS_ProgramTypes.NameE AS "PROG TYPE", -- Type of the program
    HIFIS_Program_ServiceProviders.DateStart AS "Prog at Org Start", -- Start date of the program at the organization
    HIFIS_Program_ServiceProviders.DateEnd AS "Prog at Org End", -- End date of the program at the organization
    HIFIS_Program_ServiceProviders.Comments AS "Prog at Comments", -- Comments about the program's association with the organization
    HIFIS_Organizations.ClusterID AS "Cluster ID#" -- Cluster ID for grouping

FROM HIFIS_prod.dbo.HIFIS_Programs
    -- Join with program service providers to link programs to organizations
    JOIN HIFIS_Program_ServiceProviders 
        ON HIFIS_Programs.ProgramID = HIFIS_Program_ServiceProviders.ProgramID
    -- Join with program types to get details about the program's type
    JOIN HIFIS_ProgramTypes 
        ON HIFIS_Programs.ProgramTypeID = HIFIS_ProgramTypes.ID
    -- Join with organizations to retrieve organization details
    JOIN HIFIS_Organizations 
        ON HIFIS_Program_ServiceProviders.OrganizationID = HIFIS_Organizations.OrganizationID
    -- Join with clusters to include cluster information
    JOIN HIFIS_Cluster 
        ON HIFIS_Organizations.ClusterID = HIFIS_Cluster.ClusterID

-- Filters to exclude certain data
WHERE
    HIFIS_Organizations.ClusterID NOT IN (#,#,#,#) -- Exclude these cluster IDs
    AND HIFIS_Organizations.OrganizationID <> # -- Exclude a specific organization (OrgID = #)
    -- Exclude specific program-organization combinations:
    AND NOT (HIFIS_Programs.ProgramID = # AND HIFIS_Organizations.OrganizationID IN (#,#,#)) -- Exclude certain  access points
    AND NOT (HIFIS_Programs.ProgramID = # AND HIFIS_Organizations.OrganizationID = #) 
    AND NOT (HIFIS_Programs.ProgramID = # AND HIFIS_Organizations.OrganizationID IN (#,#)) 

-- Sort the output alphabetically by program name
ORDER BY  
    HIFIS_Programs.[Name];
