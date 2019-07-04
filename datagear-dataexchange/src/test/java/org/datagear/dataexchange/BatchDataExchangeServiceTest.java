/*
 * Copyright (c) 2018 datagear.org. All Rights Reserved.
 */

package org.datagear.dataexchange;

import java.io.File;
import java.io.Reader;
import java.io.Writer;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.atomic.AtomicInteger;

import org.datagear.connection.JdbcUtil;
import org.datagear.dataexchange.support.CsvDataExport;
import org.datagear.dataexchange.support.CsvDataExportService;
import org.datagear.dataexchange.support.CsvDataImport;
import org.datagear.dataexchange.support.CsvDataImportService;
import org.junit.Assert;
import org.junit.Test;

/**
 * {@linkplain CsvBatchDataImportService}单元测试类。
 * 
 * @author datagear@163.com
 *
 */
public class BatchDataExchangeServiceTest extends DataexchangeTestSupport
{
	public static final String TABLE_NAME = "T_DATA_IMPORT";

	private BatchDataExchangeService<BatchDataExchange> batchDataExchangeService;

	public BatchDataExchangeServiceTest()
	{
		super();

		GenericDataExchangeService genericDataExchangeService = new GenericDataExchangeService();
		CsvDataImportService csvDataImportService = new CsvDataImportService(databaseInfoResolver);
		CsvDataExportService csvDataExportService = new CsvDataExportService(databaseInfoResolver);
		List<DevotedDataExchangeService<?>> devotedDataExchangeServices = new ArrayList<DevotedDataExchangeService<?>>();
		devotedDataExchangeServices.add(csvDataImportService);
		devotedDataExchangeServices.add(csvDataExportService);
		genericDataExchangeService.setDevotedDataExchangeServices(devotedDataExchangeServices);

		this.batchDataExchangeService = new BatchDataExchangeService<BatchDataExchange>(genericDataExchangeService);
	}

	@Test
	public void exchangeTest() throws Throwable
	{
		ConnectionFactory connectionFactory = new DataSourceConnectionFactory(buildTestDataSource());
		DataFormat dataFormat = new DataFormat();
		TextDataImportOption importOption = new TextDataImportOption(true, ExceptionResolve.ABORT, true);
		List<ResourceFactory<Reader>> readerFactories = new ArrayList<ResourceFactory<Reader>>();
		List<String> tables = new ArrayList<String>();

		readerFactories.add(getTestReaderResourceFactory("BatchDataExchangeServiceTest_1.csv"));
		readerFactories.add(getTestReaderResourceFactory("BatchDataExchangeServiceTest_2.csv"));

		tables.add(TABLE_NAME);
		tables.add(TABLE_NAME);

		List<CsvDataImport> csvDataImports = CsvDataImport.valuesOf(connectionFactory, dataFormat, importOption, tables,
				readerFactories);

		Set<SubDataExchange> subDataExchanges = new HashSet<SubDataExchange>();

		for (int i = 0; i < csvDataImports.size(); i++)
		{
			SubDataExchange subDataExchange = new SubDataExchange("import-" + i, csvDataImports.get(i));
			subDataExchanges.add(subDataExchange);
		}

		final AtomicInteger exportDataCount = new AtomicInteger(0);

		{
			final String subDataExchangeId = "export-1";

			ResourceFactory<Writer> writerFactory = FileWriterResourceFactory
					.valueOf(new File("target/BatchDataExchangeServiceTest.csv"), "UTF-8");
			CsvDataExport csvDataExport = new CsvDataExport(connectionFactory, dataFormat,
					new TextDataExportOption(true), new TableQuery(TABLE_NAME), writerFactory);
			csvDataExport.setListener(new TextDataExportListener()
			{
				@Override
				public void onSuccess()
				{
					println(subDataExchangeId + " : onSuccess");
				}

				@Override
				public void onStart()
				{
					println(subDataExchangeId + " : onStart");
				}

				@Override
				public void onFinish()
				{
					println(subDataExchangeId + " : onFinish");
				}

				@Override
				public void onException(DataExchangeException e)
				{
				}

				@Override
				public void onSuccess(int dataIndex)
				{
					exportDataCount.incrementAndGet();
					println(subDataExchangeId + " : onSuccess(" + dataIndex + ")");
				}

				@Override
				public void onSetNullTextValue(int dataIndex, String columnName, DataExchangeException e)
				{
				}
			});

			SubDataExchange subDataExchange = new SubDataExchange(subDataExchangeId, csvDataExport);

			Set<SubDataExchange> dependents = new HashSet<SubDataExchange>();
			dependents.addAll(subDataExchanges);
			subDataExchange.setDependents(dependents);

			subDataExchanges.add(subDataExchange);
		}

		final AtomicInteger submitSuccessCount = new AtomicInteger(0);

		BatchDataExchange batchDataExchange = new SimpleBatchDataExchange(connectionFactory, subDataExchanges);
		batchDataExchange.setListener(new BatchDataExchangeListener()
		{
			@Override
			public void onStart()
			{
				println("onStart");
			}

			@Override
			public void onFinish()
			{
				println("onFinish");
			}

			@Override
			public void onException(DataExchangeException e)
			{
				println("onException");
			}

			@Override
			public void onSuccess()
			{
				println("onSuccess");
			}

			@Override
			public void onSubmitSuccess(SubDataExchange subDataExchange)
			{
				println("onSubmitSuccess : " + subDataExchange.getId());

				submitSuccessCount.incrementAndGet();
			}

			@Override
			public void onSubmitFail(SubDataExchange subDataExchange, Throwable cause)
			{
				println("onSubmitFail : " + subDataExchange.getId());
			}

			@Override
			public void onCancel(SubDataExchange subDataExchange)
			{
				println("onCancel : " + subDataExchange.getId());
			}
		});

		Connection cn = connectionFactory.get();

		try
		{
			clearTable(cn, TABLE_NAME);

			this.batchDataExchangeService.exchange(batchDataExchange);

			batchDataExchange.getContext().waitForFinish();

			int count = getCount(cn, TABLE_NAME);

			Assert.assertEquals(6, count);
			Assert.assertEquals(3, submitSuccessCount.intValue());
			Assert.assertEquals(6, exportDataCount.get());
		}
		finally
		{
			JdbcUtil.closeConnection(cn);
		}
	}

	@Override
	protected void println()
	{
	}

	@Override
	protected void println(Object o)
	{
	}

	@Override
	protected void print(Object o)
	{
	}
}