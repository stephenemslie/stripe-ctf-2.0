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
  React.useEffect(() => {
    fetchLevel(index).then(level => {
      setLevel(level);
      setActiveSource(Object.values(level.Source)[0]);
    });
  }, []);
  React.useEffect(() => {
    Prism.highlightAll();
  }, [activeSource]);
  return level && activeSource ? (
    <div>
      <div class="bg-white rounded-t-lg border-t border-l border-r border-gray-400 p-4 mt-10">
        {Object.entries(level.Source).map(([key, source]) => {
          const active = source.Name == activeSource.Name;
          return (
            <button
              className={`rounded py-1 px-2 mr-2 text-sm focus:outline-none ${
                active
                  ? "bg-indigo-100 text-indigo-700"
                  : "text-gray-500 hover:text-indigo-600"
              }`}
              onClick={() => {
                setActiveSource(source);
              }}
            >
              {source.Basename}
            </button>
          );
        })}
      </div>
      <pre class="rounded-b-lg">
        <code className={"language-" + activeSource.Language}>
          {activeSource.Code}
        </code>
      </pre>
    </div>
  ) : (
    <div />
  );
}
