import pandas as pd 

def process_transactions(file_path):
  try: 
    df = pd.read_csv(file_path)

    df = df.drop_duplicates(subset=['transaction_id'])

    df = df.dropna(subset=['customer_id', 'amount'])

    df['amount'] = pd.to_numeric(df['amount'], errors='coerce')

    df = df[df['amount'] > 0 ]

    df = df[df["status"] == "completed"]

    if df.empty:
      raise ValueError("No valid transactions found.")
    

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