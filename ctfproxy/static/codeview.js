"use strict";

async function fetchLevel(index) {
  const response = await fetch(`/levels/${index}.json`);
  const data = await response.json();
  return data;
}

function CodeView(props) {
  const { index } = props;
  const [level, setLevel] = React.useState(null);
  const [activeSource, setActiveSource] = React.useState(null);
  const [hints, setHints] = React.useState(false);
  React.useEffect(() => {
    fetchLevel(index).then(level => {
      setLevel(level);
      setActiveSource(Object.values(level.Source)[0]);
    });
  }, []);
  React.useEffect(() => {
    Prism.highlightAll();
  }, [activeSource]);

  if (!(level && activeSource)) {
    return <div />;
  }

  return (
    <div className={hints ? "showhints" : ""}>
      <div class="bg-prism-bg rounded-t-lg p-4 mt-10 flex flex-row">
        <div class=" flex-grow">
          {Object.entries(level.Source).map(([key, source]) => {
            const active = source.Name == activeSource.Name;
            return (
              <button
                className={`rounded py-1 px-2 mr-2 text-sm focus:outline-none ${
                  active
                    ? "bg-gray-600 text-gray-300"
                    : "text-gray-500 hover:bg-gray-700"
                }`}
                onClick={() => {
                  console.log(source);
                  setActiveSource(source);
                }}
              >
                {source.Basename}
              </button>
            );
          })}
        </div>
        <div class="w-32">
          <button
            className={`rounded py-1 px-2 mr-2 text-sm focus:outline-none float-right hover:bg-gray-700 ${
              hints ? "bg-gray-600 text-gray-300" : "text-gray-500"
            }`}
            onClick={() => {
              setHints(!hints);
            }}
          >
            hints {hints ? "on" : "off"}
          </button>
        </div>
      </div>
      <pre class="rounded-b-lg">
        <code className={"language-" + activeSource.Language}>
          {activeSource.Code}
        </code>
      </pre>
    </div>
  );
}
