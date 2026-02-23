# Clinical Trial LLM Agent --------------------------------------------------

# CURRENT CONFIGURATION: Mock LLM (keyword-based)
# - Uses _mock_llm_response() for demonstration purposes
# - No API key required

# To integrate OpenAI, you would need to:
#   1. Uncomment OpenAI imports
#   2. Add OPENAI_API_KEY to .env file
#   3. Set use_real_llm=True to initialise OpenAI 

# The mock version demonstrates the full workflow (Prompt → Parse → Execute)

# Import required packages --------------------------------------------------
import pandas as pd
import json
import os
## Uncomment for real LLM integration
# from openai import OpenAI
# from dotenv import load_dotenv

## Load environment variables ------------------
## This reads OPENAI_API_KEY from the .env file when using OpenAI
# load_dotenv()

# Load data -----------------------------------------------------------------
df = pd.read_csv("adae.csv")

# Normalise columns to uppercase for consistent matching
df["AESEV"] = df["AESEV"].str.upper()
df["AETERM"] = df["AETERM"].str.upper()
df["AESOC"] = df["AESOC"].str.upper()

# Schema description --------------------------------------------------------

SCHEMA_DESCRIPTION = """
You are analyzing a clinical adverse events dataset with these columns:

- AESEV: Severity of adverse event. Possible values: MILD, MODERATE, SEVERE
- AETERM: Specific adverse event term (e.g., HEADACHE, NAUSEA, APPLICATION SITE ERYTHEMA)
- AESOC: Body system/organ class (e.g., NERVOUS SYSTEM DISORDERS, GASTROINTESTINAL DISORDERS)
- USUBJID: Unique patient identifier

When the user asks about:
- "severity", "intensity", "how serious" → use AESEV
- specific symptoms or conditions (e.g., "headache", "nausea") → use AETERM
- body systems or organ classes (e.g., "cardiac", "skin", "nervous system") → use AESOC
"""

# Clinical Trial Data Agent Class --------------------------------------------
class ClinicalTrialDataAgent:
    """
    Agent that translates natural language questions into structured Pandas queries.
    Uses an LLM to map user intent to the correct dataset column and filter value.
    """
    def __init__(self, use_real_llm=True):
        """
        Initialize the agent.
        
        Args:
            use_real_llm: If True, uses OpenAI (requires API key). 
                        If False, uses mock keyword-matchingresponses.
        """
        self.use_real_llm = use_real_llm

        # Only if use_real_llm is True
        if use_real_llm:
            self.client = OpenAI()  # Reads API key from environment if integrated
    
    # LLM Parsing - Directs to Real or Mock LLM ------------
    def parse_question(self, user_question):
        """
        Send user question to LLM and get back structured JSON.
        
        Args:
            user_question: Natural language question from user
            
        Returns:
            dict with keys: target_column, filter_value
        """
        
        if self.use_real_llm:
            return self._call_real_llm(user_question)
        else:
            return self._mock_llm_response(user_question)
    
    # Parse question through real LLM with OpenAI ------------
    def _call_real_llm(self, user_question):
        """
        Call OpenAI API with the question.
        
        Note: Requires uncommenting OpenAI imports at top of file and adding OPEN_API_KEY to .env file.
        """
        
        prompt = f"""
{SCHEMA_DESCRIPTION}

The user asked: "{user_question}"

Analyze the question and return JSON in this exact format:
{{
  "target_column": "AESEV or AETERM or AESOC",
  "filter_value": "the value to search for in UPPERCASE"
}}

Rules:
- Always return filter_value in UPPERCASE
- If asking about severity levels, use exact values: MILD, MODERATE, or SEVERE
- If asking about specific symptoms, extract the medical term (e.g., "headache" → "HEADACHE")
- If asking about body systems, use the full SOC name from the schema
"""
        
        response = self.client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            response_format={"type": "json_object"}
        )
        
        llm_output = response.choices[0].message.content
        return json.loads(llm_output)
    
 # Parse question through mock LLM ------------------ 
    def _mock_llm_response(self, user_question):
        """
        Mock LLM responses for testing without an API key.
        Uses the actual dataset values to make intelligent guesses about column and value.
        """
        question_lower = user_question.lower()
    
        # Check if any AESEV values appear in the question
        aesev_values = df["AESEV"].unique()
        for value in aesev_values:
            if value.lower() in question_lower:
                return {"target_column": "AESEV", "filter_value": value}
        
        # Check for "severity" keyword (even if no specific value mentioned)
        if "severity" in question_lower or "intensity" in question_lower or "serious" in question_lower:
            # Default to MODERATE if severity mentioned but no specific value found
            return {"target_column": "AESEV", "filter_value": "MODERATE"}
        
        # Check if any AETERM values appear in the question
        aeterm_values = df["AETERM"].unique()
        for term in aeterm_values:
            # Check if the term (or a close match) appears
            if term.lower() in question_lower or any(word in question_lower for word in term.lower().split()):
                return {"target_column": "AETERM", "filter_value": term}
        
        # Check if any AESOC values appear in the question
        aesoc_values = df["AESOC"].unique()
        for soc in aesoc_values:
            # Match keywords from the SOC name
            keywords = soc.lower().split()
            if any(keyword in question_lower for keyword in keywords if len(keyword) > 3):
                return {"target_column": "AESOC", "filter_value": soc}
        
        # Fallback: if no match found
        return {
        "error": "Could not understand the question. Please mention a severity (MILD/MODERATE/SEVERE), "
                 "a specific adverse event term, or a body system.",
        "target_column": None,
        "filter_value": None
        }
    
    # Execute the query on the dataframe based on LLM output (filter df) ------------
    def execute_query(self, parsed_output):
        """
        Apply the LLM's output to filter the dataframe.
        
        Args:
            parsed_output: dict with target_column and filter_value
            
        Returns:
            dict with subject_count and subjects list
        """
        # Check if parsing failed (fallback was triggered)
        if "error" in parsed_output:
            return {
                "error": parsed_output["error"],
                "subject_count": 0,
                "subjects": []
            }

        target_column = parsed_output["target_column"]
        filter_value = parsed_output["filter_value"]
        
        # Validate column exists
        if target_column not in df.columns:
            return {
                "error": f"Column '{target_column}' not found in dataset",
                "subject_count": 0,
                "subjects": []
            }
        
        # Filter the dataframe
        filtered = df[df[target_column] == filter_value]
        
        # Get unique subject IDs
        unique_subjects = filtered["USUBJID"].unique().tolist()
        
        return {
            "target_column": target_column,
            "filter_value": filter_value,
            "subject_count": len(unique_subjects),
            "subjects": unique_subjects
        }
    
    # End-to-end method to ask a question and get results ------------
    def ask(self, user_question):
        """
        End-to-end: question → LLM parsing → dataframe filtering → results.
        
        Args:
            user_question: Natural language question
            
        Returns:
            dict with results
        """
        print(f"\n{'='*70}")
        print(f"User Question: {user_question}")
        print(f"{'='*70}")
        
        # Step 1: Parse with LLM
        parsed = self.parse_question(user_question)
        print(f"LLM Output: {json.dumps(parsed, indent=2)}")
        
        # Step 2: Execute the query
        results = self.execute_query(parsed)
        print(f"Results: {results['subject_count']} unique subjects found")
        
        return results


# Main execution block ---------------------------------------------------
if __name__ == "__main__":
    
    # Initialise agent
    # Set use_real_llm=True to integrate OpenAI API key
    agent = ClinicalTrialDataAgent(use_real_llm=False)
    
    # Test with 3 example questions
    test_questions = [
        "Give me the subjects who had adverse events of moderate severity",
        "Show me all patients who experienced headaches",
        "Which subjects had cardiac-related adverse events?"
    ]
    
    for question in test_questions:
        result = agent.ask(question)
        print(f"Subject IDs (first 10): {result['subjects'][:10]}")
        print()