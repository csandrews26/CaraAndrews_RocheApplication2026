# Import required packages -------------------------------------------------
import pandas as pd
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel 
from typing import Optional, List
import os

# Initialise the FastAPI app -----------------------------------------------
app = FastAPI(
    title = "Clinical Trial Data API",
    description = "API for querying adverse event data from a clinical trial dataset. \n" \
    "Performs dynamic filtering and calculates subject risk scores based on AE severity."
)

# Load data from directory --------------------------------------------------
## adae.csv file should be in same directory as main.py, and must contain columns: USUBJID, AESEV, ACTARM

## Error handling issues with sourcing adae.csv
## Check file exists 
if not os.path.exists("adae.csv"):
    raise FileNotFoundError("adae.csv not found. Please ensure the file is in the same directory as main.py")

## Load dataset into pandas DataFrame with error handling
try:
    df = pd.read_csv("adae.csv")
except Exception as e:
    raise RuntimeError(f"Failed to load adae.csv: {str(e)}")

## Check required columns exist in dataframe
required_cols = ["USUBJID", "AESEV", "ACTARM"]
missing_cols = [col for col in required_cols if col not in df.columns]
if missing_cols:
    raise ValueError(f"adae.csv is missing required columns: {missing_cols}")

## Preprocess ACTARM and AESEV values to uppercase for consistent filtering
df["ACTARM"] = df["ACTARM"].str.upper()
df["AESEV"] = df["AESEV"].str.upper()

# Pydantic model for POST /ae-query request body ---------------------------
## AE Query model - defines expected JSON structure, optional fields default = none
class AEQuery(BaseModel):
    severity: Optional[List[str]] = None       # e.g. ["MILD", "MODERATE"]
    treatment_arm: Optional[str] = None        # e.g. "Placebo"

# 1: GET / -----------------------------------------------------------------
## Welcome message confirming the API is running
@app.get("/")
def root():
    return {"message": "Clinical Trial Data API is running"}

# 2: POST /ae-query --------------------------------------------------------
## Define path parameters for filtering AE records by severity and/or treatment arm
@app.post("/ae-query")
def ae_query(query: AEQuery):
    ## Words to appear on the API documentation page
    """
    Dynamically filter AE records by severity and/or treatment arm.
    Missing fields are ignored (all records returned for that dimension).
    Returns count of matching records and list of unique USUBJIDs.
    """

    ## Start with the full dataset
    filtered = df.copy()

    ## Validate input severity values
    if query.severity is not None:
        query.severity = [s.upper() for s in query.severity] # uppercase
        valid_severities = ["MILD", "MODERATE", "SEVERE"] # valid values
        invalid = [s for s in query.severity if s not in valid_severities]
        # flag error warning when invalid severity values are inputted
        if invalid:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid severity values: {invalid}. Must be one of: {valid_severities}"
            )
        
    ## Validate input treatment arm value
    if query.treatment_arm is not None:
        query.treatment_arm = query.treatment_arm.upper()
        valid_arms = df["ACTARM"].unique().tolist() # valid values
        # flag error warning when invalid treatment arm value is inputted
        if query.treatment_arm not in valid_arms:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid treatment arm: '{query.treatment_arm}'. Valid options: {valid_arms}"
            )
        filtered = filtered[filtered["ACTARM"] == query.treatment_arm]

    ## Apply severity filter only if provided
    if query.severity is not None:
        filtered = filtered[filtered["AESEV"].isin(query.severity)]

    ## Apply treatment arm filter only if provided
    if query.treatment_arm is not None:
        filtered = filtered[filtered["ACTARM"] == query.treatment_arm]

    ## Extract unique subject IDs as a list
    unique_subjects = filtered["USUBJID"].unique().tolist()

    ## Return the count of records, count of unique subjects, and the list of unique subject IDs
    return {
        "record_count": len(filtered),
        "subject_count": len(unique_subjects),
        "subjects": unique_subjects
    }

# 3: GET /subject-risk/{subject_id} -------------------------------------------
## Define path parameter for subject ID and calculate a safety risk score based on AE severity
@app.get("/subject-risk/{subject_id}")
def subject_risk(subject_id: str):
    ## Words to appear on the API documentation page
    """
    Calculate a Safety Risk Score for a specific subject.
    Weights: MILD = 1, MODERATE = 3, SEVERE = 5.
    Categories: Low < 5, Medium 5-14, High >= 15.
    Returns 404 if subject_id does not exist in the dataset.
    """
    ## Filter to this subject's AE records
    subject_df = df[df["USUBJID"] == subject_id]

    ## Return Error 404 if subject is not found in dataset
    if subject_df.empty:
        raise HTTPException(
            status_code=404,
            detail=f"Subject '{subject_id}' not found in dataset"
        )

    ## Define severity weight for each AESEV category
    severity_weights = {
        "MILD":     1,
        "MODERATE": 3,
        "SEVERE":   5
    }

    ## Calculate risk score by mapping each AESEV value to its weight and summing
    ## .get(sev, 0) returns 0 if the severity value is not in the data
    risk_score = subject_df["AESEV"].apply(
        lambda sev: severity_weights.get(sev, 0)
    ).sum()

    ## Assign risk category based on score thresholds
    if risk_score < 5:
        risk_category = "Low"
    elif risk_score < 15:
        risk_category = "Medium"
    else:
        risk_category = "High"

    ## Return the subject ID, risk score, and risk category as JSON
    return {
        "subject_id":    subject_id,
        "risk_score":    int(risk_score),
        "risk_category": risk_category
    }