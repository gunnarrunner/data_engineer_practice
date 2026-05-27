import pandas as pd 

def process_transactions(file_path):
  try: 
    # Load the data
    df = pd.read_csv(file_path)

    #-- Data Cleaning ---

    # Remove duplicate transactions

    df = df.drop_duplicates(subset=['transaction_id'])


    # Remove rows missing customer_id or amount
    df = df.dropna(subset=['customer_id', 'amount'])

    # Convert amount to numeric
    df['amount'] = pd.to_numeric(df['amount'], errors='coerce')

    # Remove invalid amounts (negative or zero)
    df = df[df['amount'] > 0 ]

    # Keep only completed transactions
    df = df[df["status"] == "completed"]

    #-- Data Cleaning ---

    if df.empty:
      raise ValueError("No valid transactions found.")
    
    #-- Aggregation ---
    aggregated = (
      df.groupby('customer_id')
      .agg(
        total_amount=('amount', 'sum'), 
        transaction_count=('transaction_id', 'count')
        )
      .reset_index()
    )
    return aggregated
  
  exceptExeption as e:
    print(f"Pipeline failed: {e}")
  
if __name__ == "__main__":
  result = process_transactions("transactions.csv")

  if result is not None:
    print(result)