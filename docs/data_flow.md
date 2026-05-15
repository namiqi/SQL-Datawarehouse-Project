graph LR
    subgraph Sources
        CRM[(CRM Folder)]
        ERP[(ERP Folder)]
    end

    subgraph Bronze_Layer
        B1[crm_sales_details]
        B2[crm_cust_info]
        B3[crm_prd_info]
        B4[erp_cust_az12]
        B5[erp_loc_a101]
        B6[erp_px_cat_g1v2]
    end

    subgraph Silver_Layer
        S1[crm_sales_details]
        S2[crm_cust_info]
        S3[crm_prd_info]
        S4[erp_cust_az12]
        S5[erp_loc_a101]
        S6[erp_px_cat_g1v2]
    end

    subgraph Gold_Layer
        F1{fact_sales}
        D1[dim_customers]
        D2[dim_products]
    end

    CRM --> B1 & B2 & B3
    ERP --> B4 & B5 & B6

    B1 --> S1 --> F1
    B2 --> S2 --> D1
    B3 --> S3 --> D2
    B4 --> S4 --> D1
    B5 --> S5
    B6 --> S6 --> D2
