import pandas as pd 

def process_transactions(file_path):
  try: 
    df = pd.read_csv(file_path)

    df = df.drop_duplicates(subset=['transaction_id'])

    df = df.dropna(subset=['customer_id', 'amount'])

    df['amount'] = pd.to_numeric(df['amount'], errors='coerce')