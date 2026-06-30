/* ============================================================
   fin.usp_ReconcileSettlements
   Compares settled amounts (fin.Settlement gross) for a date
   against the EXPECTED amount derived from order payments, by
   method, and writes fin.Reconciliation rows. Variance within the
   tolerance (config 'recon.tolerance', default 0.01) -> MATCHED,
   else UNMATCHED + an ErrorLog warning.

   Marks the underlying Settlement rows RECONCILED / DISCREPANCY.
   ============================================================ */
USE RetailDW;
GO
CREATE OR ALTER PROCEDURE fin.usp_ReconcileSettlements
    @ReconDate DATE,
    @BatchId   UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @plog BIGINT;
    EXEC util.usp_LogStart @ProcName = 'fin.usp_ReconcileSettlements', @BatchId = @BatchId, @ProcLogId = @plog OUTPUT;

    BEGIN TRY
        DECLARE @tolTxt VARCHAR(400);
        EXEC util.usp_GetConfig @ParamKey = 'recon.tolerance', @Default = '0.01', @Value = @tolTxt OUTPUT;
        DECLARE @tol DECIMAL(18,4) = ISNULL(TRY_CONVERT(DECIMAL(18,4), @tolTxt), 0.01);

        DELETE FROM fin.Reconciliation WHERE ReconDate = @ReconDate;

        ;WITH expected AS (
            SELECT PaymentMethod, SUM(Amount) AS Expected
              FROM sales.Payment
             WHERE CAST(ProcessedUtc AS DATE) = @ReconDate AND Status IN ('CAPTURED','REFUNDED')
             GROUP BY PaymentMethod
        ),
        settled AS (
            SELECT PaymentMethod, SUM(GrossAmount) AS Settled
              FROM fin.Settlement WHERE SettlementDate = @ReconDate
             GROUP BY PaymentMethod
        )
        INSERT INTO fin.Reconciliation (ReconDate, PaymentMethod, ExpectedAmount, SettledAmount, Variance, Status)
        SELECT @ReconDate,
               COALESCE(e.PaymentMethod, s.PaymentMethod),
               ISNULL(e.Expected, 0),
               ISNULL(s.Settled, 0),
               ISNULL(s.Settled,0) - ISNULL(e.Expected,0),
               CASE WHEN ABS(ISNULL(s.Settled,0) - ISNULL(e.Expected,0)) <= @tol THEN 'MATCHED' ELSE 'UNMATCHED' END
          FROM expected e
          FULL OUTER JOIN settled s ON s.PaymentMethod = e.PaymentMethod;

        UPDATE fin.Settlement
           SET Status = CASE WHEN r.Status = 'MATCHED' THEN 'RECONCILED' ELSE 'DISCREPANCY' END
          FROM fin.Settlement st
          JOIN fin.Reconciliation r ON r.ReconDate = st.SettlementDate AND r.PaymentMethod = st.PaymentMethod
         WHERE st.SettlementDate = @ReconDate;

        INSERT INTO util.ErrorLog (BatchId, ProcName, ErrorNumber, ErrorMessage)
        SELECT @BatchId, 'fin.usp_ReconcileSettlements', 0,
               CONCAT('Settlement mismatch ', PaymentMethod, ' var=', Variance)
          FROM fin.Reconciliation WHERE ReconDate = @ReconDate AND Status = 'UNMATCHED';

        EXEC util.usp_LogEnd @ProcLogId = @plog;
    END TRY
    BEGIN CATCH
        EXEC util.usp_LogError @ProcName = 'fin.usp_ReconcileSettlements', @BatchId = @BatchId;
        EXEC util.usp_LogEnd @ProcLogId = @plog, @Status = 'FAILED';
        THROW;
    END CATCH
END
GO
